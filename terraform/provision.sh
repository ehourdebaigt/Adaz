#!/bin/bash

# Source : https://blog.gripdev.xyz/2020/07/20/terraform-azure-vpn-gateway-and-openvpn-config/
set -e

# Get vars from TF State
VPN_ID=`terraform output vpn_id`
VPN_CLIENT_CERT=`terraform output client_cert`
VPN_CLIENT_KEY=`terraform output client_key`

# Replace newlines with \n so sed doesn't break
VPN_CLIENT_CERT="${VPN_CLIENT_CERT//$'\n'/\\n}"
VPN_CLIENT_KEY="${VPN_CLIENT_KEY//$'\n'/\\n}"

CONFIG_URL=`az network vnet-gateway vpn-client generate -g ad-vuln-lab --name lab-network-gw -o tsv`
wget $CONFIG_URL -O "vpnconfig.zip"
# Ignore complaint about backslash in filepaths
unzip -o "vpnconfig.zip" -d "./vpnconftemp"|| true
OPENVPN_CONFIG_FILE="./vpnconftemp/OpenVPN/vpnconfig.ovpn"

echo "Updating file $OPENVPN_CONFIG_FILE"

sed -i "s~\$CLIENTCERTIFICATE~$VPN_CLIENT_CERT~" $OPENVPN_CONFIG_FILE
sed -i "s~\$PRIVATEKEY~$VPN_CLIENT_KEY~g" $OPENVPN_CONFIG_FILE

cp $OPENVPN_CONFIG_FILE openvpn.ovpn

rm -r ./vpnconftemp
rm vpnconfig.zip