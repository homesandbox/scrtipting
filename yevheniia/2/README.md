Generate key for SSH connection

`ssh-keygen -t rsa -b 4096 -f ~/.ssh/my_ansible_key`

Create VM using terraform

`cd ias`

`terraform init`

`terraform apply -var "ssh_public_key_path=~/.ssh/my_ansible_key.pub"` 

Execute Ansible playbook
`cd ansible`

`ansible-playbook -i <tf.output.instance_public_ip>, provision_elastic.yml --extra-vars "ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/my_ansible_key"`