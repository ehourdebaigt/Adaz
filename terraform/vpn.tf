####################
#     GATEWAY      #
####################
resource "azurerm_public_ip" "gw_public_ip" {
  name                    = "lab_gateway_public_ip"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
  sku = "Standard"
}

# https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-vpn-faq#do-i-need-a-gatewaysubnet
resource "azurerm_subnet" "guests" { 
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.255.0/24"]
}

resource "azurerm_virtual_network_gateway" "gw" {
  name                = "lab-network-gw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vpnGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gw_public_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.guests.id
  }

  vpn_client_configuration {
    address_space = ["172.16.201.0/24"]// Clients will be assigned IPs from this pool
    root_certificate {
        name = "VPN-Root-CA"
        public_cert_data = data.local_file.ca_der.content
    }

    vpn_client_protocols = ["OpenVPN"]

    }
  
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Create the root certificate
resource "tls_self_signed_cert" "ca" {
  key_algorithm   = tls_private_key.example.algorithm
  private_key_pem = tls_private_key.example.private_key_pem

  # Certificate expires after 1 year
  validity_period_hours = 8766 

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 200

  # Allow to be used as a CA
  is_ca_certificate = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "cert_signing"
  ]

  # dns_names = [ azurerm_public_ip.vpn_ip.domain_name_label ]

  subject {
      common_name  = "CAOpenVPN"
      organization = "dev env"
  }
}

resource "local_file" "ca_pem" {
  filename = "caCert.pem"
  content  = tls_self_signed_cert.ca.cert_pem
}

resource "null_resource" "cert_encode" {
  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    command = "openssl x509 -in caCert.pem -outform der | base64 -w0 > caCert.der"
  }

  depends_on =  [ local_file.ca_pem ]
}

data "local_file" "ca_der" {
  filename = "caCert.der"

  depends_on = [
    null_resource.cert_encode
  ]
}

resource "tls_private_key" "client_cert" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "client_cert" {
  key_algorithm = tls_private_key.client_cert.algorithm
  private_key_pem = tls_private_key.client_cert.private_key_pem

  # dns_names = [ azurerm_public_ip.vpn_ip.domain_name_label ]

  subject {
      common_name  = "ClientOpenVPN"
      organization = "AdVulnLab"
  }
}

resource "tls_locally_signed_cert" "client_cert" {
  cert_request_pem = tls_cert_request.client_cert.cert_request_pem

  ca_key_algorithm = tls_private_key.client_cert.algorithm
  ca_private_key_pem = tls_private_key.client_cert.private_key_pem
  ca_cert_pem = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 43800

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "key_encipherment",
    "client_auth",
  ]
}

