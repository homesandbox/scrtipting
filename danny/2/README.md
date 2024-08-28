Generate key for SSH connection ubuntu user

`ssh-keygen -t rsa -b 4096 -f ~/.ssh/ubuntu_ssh_key`

Generate key for SSH connection non-root user

`ssh-keygen -t ed25519 -f ~/.ssh/non_root_ssh_key`

Set correct permissions for non root key to connect on local machine

`sudo chmod 0600 ~/.ssh/non_root_ssh_key`

Create VM using terraform

`cd ias`

`terraform init`

`terraform apply -var "ssh_public_key_path=~/.ssh/ubuntu_ssh_key.pub"` 

Execute Ansible playbook
`cd ansible`

`ansible-playbook -i <tf.output.instance_public_ip>, ec2_config.yml --extra-vars "ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ubuntu_ssh_key non_root_ssh_key_path=~/.ssh/non_root_ssh_key.pub new_user=myuser"`


Grab public key to access git from VM - TASK [Display the public SSH key] and add to git.


Connect via SSH

`ssh -i "~/.ssh/non_root_ssh_key.pub" <user_specified_in_ansible_as_new_user>@<tf.output.instance_public_ip>`


Check git connectivity

`ssh -T git@github.com`
