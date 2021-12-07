#! /bin/bash

STARTING_POINT=$(pwd)

cd ../terraform

VM_IP=$(terraform output -raw vm_ip)
VM_USER=$(terraform output -raw vm_user)

cd $STARTING_POINT

cat <<EOF > ./inventory.yml
all:
  hosts:
    $VM_IP
  vars:
    ansible_user: $VM_USER
EOF
