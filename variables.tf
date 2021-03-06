/*
  Input variable definitions for an Azure SQL Instance Pool (preview) resource and its dependences
*/

//--- Common variables definition
variable "resource_group_name" { 
    description = "The name of the resource group in which to create the Instance Pool."
    type = string
    default = "rg-instance-pool-poc"
}

variable "location" { 
    description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
    type = string
    default = "westus2"
}

variable "tags" { 
    description = "A mapping of tags to assign to the resource."
    type = map
    default = {
        environment = "development"
        product_type = "poc"
    }
}

//--- Virtual network variables
variable "vnet_name" {
    description = "The name of the virtual network. Changing this forces a new resource to be created."
    type = string
    default = "vnet-instance-pool"
}

variable "vnet_address_space" {
    description = "The address space that is used the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
    type = list(string)
    default = ["10.0.0.0/16"]
}

// Subnet variables
variable "subnet_name" {
    description = "The name of the subnet. Changing this forces a new resource to be created."
    type = string
    default = "subnet-instance-pool"
}

variable "subnet_address_prefixes" {
    description = "The address prefixes to use for the subnet."
    type = list(string)
    default     = ["10.0.2.0/24"]
}

variable "delegation_name" {
    description = "A name for the delegation in the subnet."
    type = string
    default = "delegation_name"
}

// Route table variables
variable "route_table_name" {
    description = "The name of the route table. Changing this forces a new resource to be created."
    type = string
    default = "rt_instance_pool"
}

// Network Security Group (NSG) variables
variable "nsg_name" {
    description = "Specifies the name of the network security group. Changing this forces a new resource to be created."
    type = string
    default = "nsg_instance_pool"
}

//--- Instance Pool variables
variable "instance_pool_name" { 
    description = "The name of the Instance Pool."
    type = string
    default = "instance-pool-poc"
}

variable "vcore_capacity" { 
    description = "Determines how much vCore to associate with pool."
    type = number
    default = 8
}

variable "edition" { 
    description = "The edition for the pool. Only GeneralPurpose service tier available"
    type = string
    default = "GeneralPurpose"
}

variable "compute_generation" {
    description = "The compute generation for the pool. Available only on Gen5 hardware"
    type = string
    default = "Gen5"
}

variable "license_type" {
    description = "Determines which License Type to use. BasePrice (Azure Hybrid Benefit applied) or LicenseIncluded  (Azure Hybrid Benefit not applied)"
    type = string
    default = "LicenseIncluded"
}

//--- Managed Instance variables
variable "managed_instance_name" { 
    description = "Name of the Managed Instance. It must be globally unique."
    type = string
    default = "pooled-mi-poc"
}

variable "admin_user"  { 
    description = "Administrator user name."
    type = string
    default = "yuma-user"
}

variable "admin_password" { 
    description = "Administrator user password"
    type = string
    default = "Passw0rd1234Passw0rd1234"
}

variable "mi_vcore_capacity" { 
    description = "Determines how much vCore to associate with instance."
    type = number
    default = 4
}

variable "storage_gb" { 
    description = "Determines how much Storage size to associate with instance."
    type = number
    default = 32
}

variable "mi_edition" { 
    description = "The edition for the instance. Accepted values: GeneralPurpose or BusinessCritical"
    type = string
    default = "GeneralPurpose"
}

variable "mi_compute_generation" {
    description = "The compute generation for the instance. Gen5 or Gen4 (availability depends on selected region)"
    type = string
    default = "Gen5"
}

variable "mi_license_type" { 
    description = "Determines which License Type to use. BasePrice (Azure Hybrid Benefit applied) or LicenseIncluded  (Azure Hybrid Benefit not applied)"
    type = string
    default = "LicenseIncluded"
}

variable "managed_database_name" { 
    description = "Name of the database to create inside the Managed Instance"
    type = string
    default = "pooled-managed-database-poc"
}

//--- Test VNet variables
variable "vnet_test_name" {
    description = "The name of the virtual network for testing Managed Instance access."
    type = string
    default = "vnet-test"
}

variable "vnet_test_address_space" {
    description = "The name of the virtual network for testing Managed Instance access."
    type = list(string)
    default = ["10.2.0.0/16"]
}

variable "subnet_test_name" {
    description = "The name of the virtual network for testing Managed Instance access."
    type = string
    default = "subnet-test"
}

variable "subnet_test_address_prefixes" {
    description = "The name of the virtual network for testing Managed Instance access."
    type = list(string)
    default = ["10.2.0.0/24"]
}

//--- VNet Peerings variables
variable "vnet_test_peering_name" {
    description = "Name of the peering in testing virtual netowork."
    type = string
    default = "vnet-test-peering"
}

variable "vnet_managed_instance_peering_name" {
    description = "Name of the peering in the Managed Instance virtual netowork."
    type = string
    default = "vnet-managed-instance-peering"
}

//--- Virtual machines variables for testing
// Ip of the Virtual machine
variable "azurerm_public_ip_name" {
    description = "The name of the Ip"
    type = string
    default = "test-pip"  
}
variable "azurerm_public_ip_allocation_method" {
    description = "ip allocation method"
    type = string
    default = "Dynamic"  
}
variable "azurerm_public_ip_idle_timeout_in_minutes" {
    description = "timeout in minutes"
    type = number
    default = 30
}
variable "azurerm_public_ip_enviroment" {
    description = "ip enviroment"
    type = string
    default = "dev"
}
// Network Interface of the Virtual machine
variable "azurerm_network_interface_name" {
    description = "network interface name"
    type = string
    default = "interface"
}
variable "ip_configuration_name" {
    description = "ip configuration name"
    type = string
    default = "testconfiguration1"
}
variable "private_ip_address_allocation" {
    description = "private ip address allocation"
    type = string
    default = "Dynamic"
}
variable "private_ip_address" {
    description = "private ip address allocation"
    type = string
    default = "10.0.1.5"
} 
// Virtual machine to test connectiom
variable "azurerm_virtual_machine_name" {
    description = "(Required) Specifies the name of the Virtual Machine. Changing this forces a new resource to be created."
    type = string
    default = "vmep"
}
variable "azurerm_virtual_machine_vm_size" {
    description = "(Required) Specifies the size of the Virtual Machine."
    type = string
    default = "Standard_B2s"
}
variable "storage_image_reference_publisher" {
    description = "(Required) Specifies the publisher of the image used to create the virtual machine. Changing this forces a new resource to be created."
    type = string
    default = "MicrosoftWindowsServer"
}
variable "storage_image_reference_offer" {
    description = " (Required) Specifies the offer of the image used to create the virtual machine. Changing this forces a new resource to be created."
    type = string
    default = "WindowsServer"
}
variable "storage_image_reference_sku" {
    description = "(Required) Specifies the SKU of the image used to create the virtual machine. Changing this forces a new resource to be created."
    type = string
    default = "2019-Datacenter"
}
variable "storage_image_reference_version" {
    description = "(Optional) Specifies the version of the image used to create the virtual machine. Changing this forces a new resource to be created."
    type = string
    default = "latest"
}
variable "storage_os_disk_name" {
    description = "storage os disk name"
    type = string
    default = "server-os"
}
variable "storage_os_disk_caching" {
    description = "(Optional) Specifies the caching requirements for the Data Disk. Possible values include None, ReadOnly and ReadWrite."
    type = string
    default = "ReadWrite"
}
variable "storage_os_disk_create_option" {
    description = " (Required) Specifies how the data disk should be created. Possible values are Attach, FromImage and Empty."
    type = string
    default = "FromImage"
}
variable "storage_os_disk_managed_disk_type" {
    description = "(Optional) Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS."
    type = string
    default = "Standard_LRS"
}

variable "os_profile_computer_name" {
    description = "(Required) Specifies the name of the Virtual Machine."
    type = string
    default = "vmep"
}
variable "os_profile_admin_username" {
    description = "(Required) Specifies the name of the local administrator account."
    type = string
    default = "adminUsername"
}
variable "os_profile_admin_password" {
    description = "(Optional) Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS."
    type = string
    default = "Passw0rd1234"
}
variable "os_profile_windows_config_provision_vm_agent" {
    description = "(Optional) Should the Azure Virtual Machine Guest Agent be installed on this Virtual Machine? Defaults to false."
    type = bool
    default = true
}
variable "os_profile_windows_config_protocol" {
    description = "(Required) Specifies the protocol of listener. Possible values are HTTP or HTTPS."
    type = string
    default = "HTTP" 
}
// Virtual machine Extension
variable "vm_extension_name" {
    description = "(Required) The name of the virtual machine extension peering. Changing this forces a new resource to be created."
    type = string
    default = "vm_extension" 
}
variable "vm_extension_publisher" {
    description = "(Required) The publisher of the extension, available publishers can be found by using the Azure CLI."
    type = string
    default = "Microsoft.Compute" 
}
variable "vm_extension_type" {
    description = "(Required) The type of extension, available types for a publisher can be found using the Azure CLI."
    type = string
    default = "CustomScriptExtension" 
}
variable "vm_extension_type_handler_version" {
    description = "(Required) The type of extension, available types for a publisher can be found using the Azure CLI."
    type = string
    default = "1.8" 
}
variable "vm_extension_auto_upgrade_minor_version" {
    description = "(Optional) Specifies if the platform deploys the latest minor version update to the type_handler_version specified."
    type = bool
    default = true
}
