data "azurerm_public_ip" "main" {
  name                = azurerm_public_ip.gw_public_ip.name
  resource_group_name = var.resource_group
  depends_on          = [azurerm_public_ip.gw_public_ip]
}
