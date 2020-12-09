resource "azurerm_network_interface" "workstation" {
  count = length(local.domain.workstations)

  name                = "${var.prefix}-wks-${count.index}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "static"
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Static"
    private_ip_address = cidrhost(var.vms_subnet_cidr, count.index+10)
  }
}

resource "azurerm_virtual_machine" "workstation" {
  count = length(local.domain.workstations)
  
  name                  = local.domain.workstations[count.index].name
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.workstation[count.index].id]
  vm_size               = var.workstations_vm_size

  # Delete OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Delete data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    #id = data.azurerm_image.workstation.id

    # az vm image list -f "Windows-10" --all
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    # gensecond: see https://docs.microsoft.com/en-us/azure/virtual-machines/windows/generation-2
    sku       = "19h1-pron"
    version   = "latest"
  }

  storage_os_disk {
    name              = "wks-${count.index}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = local.domain.workstations[count.index].name
    admin_username = local.domain.default_local_admin.username
    admin_password = local.domain.default_local_admin.password
  }

  os_profile_windows_config {
      enable_automatic_upgrades = false
      provision_vm_agent = true
      timezone = "Eastern Standard Time"
      winrm {
        protocol = "HTTP"
      }
  }

  tags = {
    kind = "workstation"
  }
}

# While this is part of the DevTest Labs service in Azure, 
# this resource applies only to standard VMs, not DevTest Lab VMs.
# Resources will be deallocated
resource "azurerm_dev_test_global_vm_shutdown_schedule" "workstation" {
  count = length(local.domain.workstations)

  virtual_machine_id = azurerm_virtual_machine.workstation[count.index].id
  location           = azurerm_resource_group.main.location
  enabled            = true

  daily_recurrence_time = "2300" ## HHmm format where HH (0-23) and mm (0-59)
  timezone              = "Eastern Standard Time"

  notification_settings {
    enabled         = false
    time_in_minutes = "60"
    webhook_url     = ""
  }
}
