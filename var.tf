variable "location" {
  type = string
  default = "westus"
}

variable "resource_group_name" {
    type = string
    default = "RGterraform"
}


### Network Variables

variable "virtual_network_name" {
  type = string
  default     = "terraform-vnet"
}

variable "subnet_name" {
  type = string
  default     = "jenkins-subnet"
}

variable "public_ip_name" {
  type = string
  default     = "jenkins-pip"
}

variable "public_ip_name2" {
  type = string
  default     = "jenkins-pip2"
}

variable "network_security_group_name" {
  default     = "allow-all"
}

variable "network_interface_name" {
  type = string
  default     = "jenkins-nic"
}

variable "network_interface_name2" {
  type = string
  default     = "jenkins-nic2"
}


### Virtual Machine Variables

variable "virtual_machine_name" {
  default     = "jenkins-master"
}

variable "virtual_machine_name2" {
  default     = "jenkins-node"
}

variable "virtual_machine_size" {
  default     = "Standard_D2s_v3"
}

variable "virtual_machine_osdisk_name" {
  default     = "jenkins-osdisk"
}

variable "virtual_machine_osdisk_name2" {
  default     = "jenkinsnode-osdisk"
}

variable "virtual_machine_osdisk_type" {
  default     = "Standard_LRS"
}

variable "virtual_machine_computer_name" {
  default     = "master-jenkins"
}

variable "virtual_machine_computer_name2" {
  default     = "node-jenkins"
}

variable "admin_username" {
  default     = "vmadmin"
}

variable "admin_password" {
  default     = "April@123456789"
}