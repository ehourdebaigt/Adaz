resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-dc-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "static"
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Static"
    private_ip_address = cidrhost(var.vms_subnet_cidr, 20)
  }
}

resource "azurerm_virtual_machine" "dc" {
  name                  = "domain-controller"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = var.dc_vm_size

  # Delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Delete data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "DOMAIN-NAME-DC"
    admin_username = local.domain.initial_domain_admin.username
    admin_password = local.domain.initial_domain_admin.password
  }

  os_profile_windows_config {
      enable_automatic_upgrades = false
      provision_vm_agent = true
      timezone = "Eastern Standard Time"
      winrm {
        protocol = "HTTP" # TODO change to HTTPS
      }
  }
}
# While this is part of the DevTest Labs service in Azure, 
# this resource applies only to standard VMs, not DevTest Lab VMs.
# Resources will be deallocated
resource "azurerm_dev_test_global_vm_shutdown_schedule" "domain-controlleer" {
  virtual_machine_id = azurerm_virtual_machine.dc.id
  location           = azurerm_resource_group.main.location
  enabled            = true

  daily_recurrence_time = "2300" ## HHmm format where HH (0-23) and mm (0-59)
  timezone              = "Eastern Standard Time"

  notification_settings {
    enabled         = false
    time_in_minutes = "60"
    webhook_url     = ""
  }
  
  tags = {
    kind = "domain-controller"
  }
}