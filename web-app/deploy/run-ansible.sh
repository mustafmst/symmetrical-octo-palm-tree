#! /bin/bash

./setup-inventory.sh

ansible-playbook playbook.yaml -i inventory.yml