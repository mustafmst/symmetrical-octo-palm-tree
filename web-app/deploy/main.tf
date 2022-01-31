# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

provider "tls" {
}

# create resource group
resource "azurerm_resource_group" "rg" {
  name     = "terraformTestGroup"
  location = "germanywestcentral"
}

# create vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "terraformVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# create public subnet
resource "azurerm_subnet" "public" {
  name                 = "public"
  address_prefixes     = ["10.0.0.0/24"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

# create private subnet
resource "azurerm_subnet" "private" {
  name                 = "private"
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

# create route table
resource "azurerm_route_table" "rt" {
  name                = "terraformRouteTable"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name           = "toPrivateSubnet"
    address_prefix = "10.0.1.0/24"
    next_hop_type  = "VirtualNetworkGateway"
  }
}

# connect route table with public subnet
resource "azurerm_subnet_route_table_association" "snrt1" {
  subnet_id      = azurerm_subnet.public.id
  route_table_id = azurerm_route_table.rt.id
}

# create public ip for vm
resource "azurerm_public_ip" "pubip" {
  name                = "terraformVMsPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "mst-terraform-jenkins"
}

# create network security group with ssh, http and https rules
resource "azurerm_network_security_group" "nsg" {
  name                = "terraformNetworkSecGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 330
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# create networn interface for public vm
resource "azurerm_network_interface" "nic" {
  name                = "terraformNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipConfig1"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubip.id
  }
}

# connect interface with security group
resource "azurerm_network_interface_security_group_association" "nic-nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create (and display) an SSH key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# create public proxy vm
resource "azurerm_linux_virtual_machine" "vm_proxy" {
  name                  = "VM_proxy"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "VM_proxyDisc"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  computer_name                   = "VM_proxy"
  admin_username                  = "mustaf"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "mustaf"
    public_key = tls_private_key.ssh.public_key_openssh
  }
}


# create networn interface for private vm
resource "azurerm_network_interface" "nic_app" {
  name                = "terraformNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipConfig1"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Static"
  }
}


# connect interface with security group
resource "azurerm_network_interface_security_group_association" "nic-nsg_app" {
  network_interface_id      = azurerm_network_interface.nic_app.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# create private app vm
resource "azurerm_linux_virtual_machine" "vm_app" {
  name                  = "VM_app"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic_app.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "VM_appDisc"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  computer_name                   = "VM_app"
  admin_username                  = "mustaf"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "mustaf"
    public_key = tls_private_key.ssh.public_key_openssh
  }
}

# output data 

output "tls_private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}

output "vm_ip" {
  value = azurerm_public_ip.pubip.ip_address
}

output "vm_proxy_user" {
  value = azurerm_linux_virtual_machine.vm_proxy.admin_username
}

output "vm_app_user" {
  value = azurerm_linux_virtual_machine.vm_app.admin_username
}

output "vm_fqdn" {
  value = azurerm_public_ip.pubip.fqdn
}