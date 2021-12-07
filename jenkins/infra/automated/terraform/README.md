# Automate creation of cloud Jenkins infra

This topic is the same exercise as above with one difference. Automate everything by using "Infrastructure as a Code" tools. Save all steps in a Git repository.

* Deploy above infrastructure using Terraform
* To configure Linux machine use Ansible (or similar tool)

## running

```bash
terraform init
terraform validate
terraform apply

terraform output -raw tls_private_key > ~/.ssh/id_rsa_terraform_vm
chmod 600 ~/.ssh/id_rsa_terraform_vm

cat <<EOF >> ~/.ssh/config

Host terraform_vm
    HostName $(terraform output -raw vm_ip)
    IdentityFile ~/.ssh/id_rsa_terraform_vm
    User $(terraform output -raw vm_user)

EOF
```
