// Azure provider configuration
terraform {
  required_version = ">= 0.12"
  backend "azurerm" {}
}
provider "azurerm" {
    version = "~>2.0"
    features {}
	subscription_id = "a7b78be8-6f3c-4faf-a43d-285ac7e92a05"
	tenant_id       = "c160a942-c869-429f-8a96-f8c8296d57db"
 }
// Configure GUID generator to use it as a suffix when needed
resource "random_uuid" "poc" { }

// Create Resource Group
resource "azurerm_resource_group" "rg" {

    // Arguments required by Terraform API
    name = join(local.separator, [var.resource_group_name, random_uuid.poc.result])
    location = var.location

    // Optional Terraform resource manager arguments but required by architecture
    tags = var.tags
}

//--- Create dedicated Virtual Network (VNet) to host the Instance Pool
resource "azurerm_virtual_network" "vnet" {
  
    // Arguments required by Terraform API
    name = var.vnet_name
    address_space = var.vnet_address_space
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

// Create associated subnet
resource "azurerm_subnet" "subnet" {
  
    // Arguments required by Terraform API
    name = var.subnet_name
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = var.subnet_address_prefixes

    // Optional Terraform arguments but required by Instance Pool architecture
    delegation {
        name = var.delegation_name
        service_delegation {
            name = local.service_delegation_name
            actions = ["Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }
    }
}

// Create Network Security Group and associate to subnet
resource "azurerm_network_security_group" "nsg" {
  
    // Arguments required by Terraform API
    name = var.nsg_name
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    tags = var.tags

    // Inbound rules required to redirect connection type
    security_rule {
        name = "AllowTcpInbound_Redirect"
        priority = 1000
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_ranges = ["1433"]
        source_address_prefix = "VirtualNetwork"
        destination_address_prefix = "*"
    }

    security_rule {
        name = "allow_redirect_inbound"
        priority = 1100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_ranges = ["11000-11999"]
        source_address_prefix = "VirtualNetwork"
        destination_address_prefix = "*"
    }

    security_rule {
        name = "allow_geodr_inbound"
        priority = 1200
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_ranges = ["5022"]
        source_address_prefix = "VirtualNetwork"
        destination_address_prefix = "*"
    }
}

// Associate subnet to Network Security Group
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  
    // Arguments required by Terraform API
    subnet_id = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

// Create Route Table and associate to subnet
resource "azurerm_route_table" "rt" {
  
    // Arguments required by Terraform API
    name = var.route_table_name
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    // Optional Terraform resource manager arguments but required by architecture
    tags = var.tags
}

// Associate subnet to Network Security Group
resource "azurerm_subnet_route_table_association" "rt_association" {
  
    // Arguments required by Terraform API
    subnet_id = azurerm_subnet.subnet.id
    route_table_id = azurerm_route_table.rt.id
}

//--- Create additional virtual network to validate Managed Instance access from private network
resource "azurerm_virtual_network" "vnet_test" {
  
    name = var.vnet_test_name
    address_space = var.vnet_test_address_space
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    tags = var.tags
}

// Create associated subnet
resource "azurerm_subnet" "subnet-test" {
  
  name = var.subnet_test_name
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_test.name
  address_prefixes = var.subnet_test_address_prefixes
}

//--- Create VNet Peerings to connect both VNets: Managed Instance VNet and testing VNet
resource "azurerm_virtual_network_peering" "vnet-test-peering" {
  
  name = var.vnet_test_peering_name
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_test.name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_virtual_network_peering" "vnet-managed-instance-peering" {
  
  name = var.vnet_managed_instance_peering_name
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_test.id
}

//--- Create Instance Pool (not supported by Terraform native API)
resource "null_resource" "create_instance_pool" { 

    provisioner local-exec {

        command = <<-EOT
            az sql instance-pool create \
                --name ${join(local.separator, [var.instance_pool_name, random_uuid.poc.result])} \
                --capacity ${var.vcore_capacity} \
                --edition ${var.edition} \
                --family ${var.compute_generation} \
                --license-type ${var.license_type} \
                --location ${azurerm_resource_group.rg.location} \
                --resource-group ${azurerm_resource_group.rg.name} \
                --subnet ${azurerm_subnet.subnet.id}
    EOT
    }

    // Instance Pool must be created after Network Security Group and Route Table have been configured to its subnet 
    depends_on = [
        azurerm_subnet_network_security_group_association.nsg_association,
        azurerm_subnet_route_table_association.rt_association
    ]
}

//--- Create Virtual Machine with Azure Data Studio to test connectivity to the instance/database
//ip
resource "azurerm_public_ip" "ip" {
  name                    = var.azurerm_public_ip_name
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = var.azurerm_public_ip_allocation_method
  idle_timeout_in_minutes = var.azurerm_public_ip_idle_timeout_in_minutes
  tags = {
    environment = var.azurerm_public_ip_enviroment
  }
}
// Network Interface
resource "azurerm_network_interface" "ni" {
  name                = var.azurerm_network_interface_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = azurerm_subnet.subnet-test.id
    private_ip_address_allocation = var.private_ip_address_allocation
    //private_ip_address            = var.private_ip_address
    public_ip_address_id          = azurerm_public_ip.ip.id

  }
}
// virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = var.azurerm_virtual_machine_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.ni.id]
  vm_size               = var.azurerm_virtual_machine_vm_size

  storage_image_reference {
    publisher = var.storage_image_reference_publisher
    offer     = var.storage_image_reference_offer
    sku       = var.storage_image_reference_sku
    version   = var.storage_image_reference_version
  }

  storage_os_disk {
    name              = var.storage_os_disk_name
    caching           = var.storage_os_disk_caching
    create_option     = var.storage_os_disk_create_option
    managed_disk_type = var.storage_os_disk_managed_disk_type
  }

    os_profile {
    computer_name      = var.azurerm_virtual_machine_name
    admin_username     = var.os_profile_admin_username 
    admin_password     = var.os_profile_admin_password 
  
  }

  os_profile_windows_config {
    provision_vm_agent = var.os_profile_windows_config_provision_vm_agent
  winrm  {  //Here defined WinRM connectivity config
      protocol = var.os_profile_windows_config_protocol  
    }
  }
}
//  virtual machine extension
resource "azurerm_virtual_machine_extension" "vm_extension" {
  name                       = var.vm_extension_name
  virtual_machine_id         = azurerm_virtual_machine.vm.id
  publisher                  = var.vm_extension_publisher
  type                       = var.vm_extension_type
  type_handler_version       = var.vm_extension_type_handler_version
  auto_upgrade_minor_version = var.vm_extension_auto_upgrade_minor_version

  settings = <<SETTINGS
    {
    "commandToExecute": "Powershell -c Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); choco install azure-data-studio -y"
    }
SETTINGS
}
