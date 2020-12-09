# Active Directory Lab with VPN Access

This project allows you to easily spin up a Active Directory lab with Terraform and Ansible in Azure and access it through a VPN connection.

### Prerequisites

- An Azure subscription. You can [create one for free](https://azure.microsoft.com/en-us/free/) and you get $200 of credits for the first 30 days. Note that this type of subscription has a limit of 4 vCPUs per region.

- [Terraform](https://www.terraform.io/downloads.html)

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

- You must be logged in to your Azure account by running `az login`. You can use `az account list` to confirm you have access to your Azure subscription

### Installation

- Clone this repository

```
git clone https://github.com/ehourdebaigt/Adaz.git
```

- Install Ansible in a virtual environment

```
cd ansible/
python3 -m venv ansible/venv 
source ansible/venv/bin/activate
pip install -r ansible/requirements.txt
ansible-galaxy collection install ansible.windows
``` 

### Usage

- Create resources in Azure and configure the VPN gateway (this step takes 30 to 60 minutes.)
```bash
cd terraform
teraform login
terraform init
terraform apply
./provision.sh
``` 

- Connect to the VPN Gateway and provision resources
```
openvpn --config openvpn.log &
ansible-playbook domain-controllers.yml -v
ansible-playbook workstations.yml -v
deactivate
``` 

### Costs

Azure VPN Gateways are very costly. They cost roughly twice as much as the VMs (about 140USD per month). Contrarily to VMs you cannot deallocate a VPN gateway resource to save money. 

### Destroy
Simply run `terraform destroy` when you are done with the lab. 