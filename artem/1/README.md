Get latest Ubuntu image

```shell
aws ec2 describe-images \
    --owners 099720109477 \
    --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-*" \
              "Name=architecture,Values=x86_64" \
              "Name=virtualization-type,Values=hvm" \
    --query "Images | sort_by(@, &CreationDate)[-1].ImageId" \
    --output text
```

Generate key for SSH connection ubuntu user

`ssh-keygen -t rsa -b 4096 -f ~/.ssh/ubuntu_ssh_key`

Create VM using terraform

`terraform init`

`terraform apply -var "ssh_public_key_path=~/.ssh/ubuntu_ssh_key.pub" -var "ssh_private_key_path=~/.ssh/ubuntu_ssh_key"` 

Connect via SSH

`ssh ubuntu@<TF_OUPUT_IP> -i ~/.ssh/ubuntu_ssh_key`