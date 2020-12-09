variable "domain_config_file" {
    description = "Path to the domain configuration file"
    default = "../ansible/domain.yml"
}

variable "vms_subnet_cidr" {
    description = "CIDR to use for the VMs subnet"
    default = "10.0.1.0/24"
}

variable "region" {
    description = "Azure region in which resources should be created. See https://azure.microsoft.com/en-us/global-infrastructure/locations/"
    default = "East US 2"
}

variable "resource_group" {
    # Warning: see https://github.com/christophetd/adaz/blob/master/doc/faq.md#how-to-change-the-name-of-the-resource-group-in-which-resources-are-created
    description = "Resource group in which resources should be created. Will automatically be created and should not exist prior to running Terraform"
    default = "ad-vuln-lab"
}

variable "dc_vm_size" {
    description = "Size of the Domain Controller VM. See https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs"
    default = "Standard_D1_v2"
}

variable "workstations_vm_size" {
    description = "Size of the workstations VMs. See https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs"
    default = "Standard_D1_v2" 
}

