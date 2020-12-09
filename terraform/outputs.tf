output "gw_public_ip" {
  value = azurerm_public_ip.gw_public_ip.ip_address
}
output "client_cert" {
  value = tls_locally_signed_cert.client_cert.cert_pem
}
output "client_key" {
  value = tls_private_key.client_cert.private_key_pem
}
output "vpn_id" {
  value = azurerm_virtual_network_gateway.gw.id
}