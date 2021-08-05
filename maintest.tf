provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

data "azurerm_public_ip" "pip" {
    name                = azurerm_public_ip.pip.name
    resource_group_name = azurerm_public_ip.pip.resource_group_name
    depends_on          = [azurerm_public_ip.pip]
}

output "pip" {
       value = "${data.azurerm_public_ip.pip.ip_address}"
   }

resource "azurerm_network_security_group" "allows" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allall"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                      = var.network_interface_name
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  
  ip_configuration {
    name                          = "${var.network_interface_name}-configuration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

### Jenkins Master

resource "azurerm_virtual_machine" "vm" {
  name                  = var.virtual_machine_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = var.virtual_machine_size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = var.virtual_machine_osdisk_name
    create_option     = "FromImage"
    managed_disk_type = var.virtual_machine_osdisk_type
  }

  os_profile {
    computer_name  = var.virtual_machine_computer_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
   os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
  inline = [
      "sudo apt-get update",

      # JDK installation
      "sudo apt install default-jdk -y",

      # Jenkins
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt update",
      "sudo apt install jenkins -y",
      "sudo systemctl start jenkins",
    ]
  connection {
      type = "ssh"
      user = var.admin_username
      password = var.admin_password
      host = data.azurerm_public_ip.pip.ip_address
  }
  }
}

### Jenkins node install 
  resource "azurerm_public_ip" "pip2" {
  name                = var.public_ip_name2
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

data "azurerm_public_ip" "pip2" {
    name                = azurerm_public_ip.pip2.name
    resource_group_name = azurerm_public_ip.pip2.resource_group_name
    depends_on          = [azurerm_public_ip.pip2]
}

output "pip2" {
       value = "${data.azurerm_public_ip.pip2.ip_address}"
   }

  resource "azurerm_network_interface" "nic2" {
  name                      = var.network_interface_name2
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  
  ip_configuration {
    name                          = "${var.network_interface_name2}-configuration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip2.id
  }
}

  resource "azurerm_virtual_machine" "vm2" {
  name                  = var.virtual_machine_name2
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = ["${azurerm_network_interface.nic2.id}"]
  vm_size               = var.virtual_machine_size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = var.virtual_machine_osdisk_name2
    create_option     = "FromImage"
    managed_disk_type = var.virtual_machine_osdisk_type
  }

  os_profile {
    computer_name  = var.virtual_machine_computer_name2
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
   os_profile_linux_config {
    disable_password_authentication = false
  }
  
   provisioner "remote-exec" {
  inline = [
      # Build Essentials,
      "sudo apt-get update",
      "sudo apt-get install build-essential -y",
      "sudo apt-get install unzip -y",
      "sudo apt-get install make -y",
      # JDK installation
      "sudo apt install default-jdk -y",

      #git installation,
      "sudo apt install git",

      #maven installation,
      "sudo apt-get -y install maven -y",

     #Ansible installation,
      "sudo apt update",
      "sudo apt install software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y",

      #Docker installation,
      "sudo apt-get update",
      "sudo apt install apt-transport-https ca-certificates curl software-properties-common -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
      "sudo apt-get update",
      "sudo apt-cache policy docker-ce",
      "sudo apt-get install -y docker-ce",

      #Azure CLI installation
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
     
    ]
 connection {
      type = "ssh"
      user = var.admin_username
      password = var.admin_password
      host = data.azurerm_public_ip.pip2.ip_address
  }
  }
}  