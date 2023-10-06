locals {
  name                 = "jenkins"
  username             = "azureuser"
  ssh_public_key_path  = "./jenkins.pub"
  ssh_private_key_path = "./jenkins"
}

data "azurerm_resource_group" "jenkins" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "jenkins" {
  name                = local.name
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.jenkins.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "jenkins" {
  name                 = local.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.jenkins.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "jenkins" {
  name                = local.name
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.jenkins.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "jenkins" {
  name                = "jenkins-nic"
  location            = data.azurerm_resource_group.jenkins.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jenkins.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins.id
  }
}

resource "azurerm_linux_virtual_machine" "jenkins" {
  name                = "jenkins-machine"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.jenkins.location
  size                = "Standard_D2s_v4"
  admin_username      = local.username
  network_interface_ids = [
    azurerm_network_interface.jenkins.id,
  ]

  admin_ssh_key {
    username   = local.username
    public_key = file(local.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "null_resource" "ansible-install-jenkins" {

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Verified ssh connection'"]

    connection {
      type        = "ssh"
      user        = local.username
      private_key = file(local.ssh_private_key_path)
      host        = azurerm_public_ip.jenkins.ip_address
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook  -i ${azurerm_public_ip.jenkins.ip_address}, --private-key ${local.ssh_private_key_path} playbook.yaml"
  }

  depends_on = [
    azurerm_linux_virtual_machine.jenkins
  ] 
}