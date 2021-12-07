# Runn all

```bash
cd terraform
./apply.sh
cd ../ansible
./setup-inventory.sh
ansible-playbook playbook.yaml -i inventory.yml
```