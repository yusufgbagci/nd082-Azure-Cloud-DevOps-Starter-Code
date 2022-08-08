provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "cloud-shell-storage-westeurope"
  location = "West Europe"
}

data "azurerm_image" "main" {
  name                = "myPackerImageNew"
  resource_group_name = "cloud-shell-storage-westeurope"
}
output "image_id" {
  value = "/subscriptions/910fc539-3c29-4162-aeb4-18611f1f1450/resourceGroups/cloud-shell-storage-westeurope/providers/Microsoft.Compute/images/myPackerImageNew"
}

locals {
  instance_count = 2
}
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-SG"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  security_rule {
    name                       = "Udacity"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }
  tags = var.tags
}
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = var.tags
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = var.tags
}
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = var.tags
}
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_nat_rule" "main" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "HTTPSAccess"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.main.frontend_ip_configuration[0].name
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                          = var.vm_count 
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
  ip_configuration_name          = "primary"
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
}

# Create a virtual machine availability set
resource "azurerm_availability_set" "avset" {
  name                           = "${var.prefix}avset"
  location                       = azurerm_resource_group.main.location
  resource_group_name            = azurerm_resource_group.main.name
  platform_fault_domain_count    = 2
  platform_update_domain_count   = 2
  managed                        = true

  tags = var.tags
}

resource "azurerm_network_interface" "main" {
  count                          = var.vm_count
  name                           = "${var.prefix}-${count.index}-nic"
  location                       = azurerm_resource_group.main.location
  resource_group_name            = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_virtual_machine" "main" {
  count                            = var.vm_count 
  name                             = "${var.prefix}VM-${count.index}"
  location                         = azurerm_resource_group.main.location
  resource_group_name              = azurerm_resource_group.main.name
  availability_set_id              = azurerm_availability_set.avset.id
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]
  vm_size                          = "Standard_DS2_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.main.id}"
  }

  storage_os_disk {
    name              = "${var.prefix}OS-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
}

  os_profile {
    computer_name  = "APPVM"
    admin_username = "bagci4852@gmail.com"
    admin_password = "Albay.6544"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
 
  tags = var.tags
}