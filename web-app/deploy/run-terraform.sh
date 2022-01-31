#! /bin/bash

az login

terraform init
terraform validate
terraform apply

terraform output -raw tls_private_key > ~/.ssh/id_rsa_terraform_vm
chmod 600 ~/.ssh/id_rsa_terraform_vm
ssh-add ~/.ssh/id_rsa_terraform_vm

cat <<EOF >> ~/.ssh/config

Host terraform_vm
    HostName $(terraform output -raw vm_ip)
    IdentityFile ~/.ssh/id_rsa_terraform_vm
    User $(terraform output -raw vm_user)

EOF