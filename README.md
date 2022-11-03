# Provision VMs on KVM with Terraform 

- Website: https://www.terraform.io

## Requirements

-	[Terraform](https://www.terraform.io/downloads.html) Terraform v1.0.11+
-	[terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt) dmacvicar/libvirt v0.6.11+
-   [terraform-provider-template](https://github.com/hashicorp/terraform-provider-template) hashicorp/template v2.2.0+


## as a user download terraform, unzip, move to your bin PATH
```
wget https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip
unzip terraform_1.0.11_linux_amd64.zip
mv terraform $HOME/.local/bin
```

## as a root install with yum or apt
```
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform
```

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt install terraform
```

## check terraform version
[kraslan@zfwxtest04 ~]$ ```terraform version```

Terraform v1.0.11
on linux_amd64

## generate public private keys
[kraslan@zfwxtest04 projekts]$ `ssh-keygen`

## copy your public key to server fw156 to /root/.ssh/authorized_keys
[kraslan@zfwxtest04 projekts]$ `ssh-copy-id root@fw156`

## check connection to server without password

[kraslan@zfwxtest04 projekts]$ `ssh root@9.152.91.156`
```
Activate the web console with: systemctl enable --now cockpit.socket
Last login: Wed Oct 13 07:35:05 2021
```

## instance the provider
```
provider "libvirt" {
     uri = "qemu+ssh://root@9.152.91.156/system?knownhosts=./known_hosts"
}
```

## terraform comand, initialize, plan to see what is going to be created, apply will create resorces, and destroy is to come back, to delete all,
```
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```

## provisioning and debuging your script,
```
TF_LOG=DEBUG terraform apply -auto-approve
TF_LOG_PROVIDER=TRACE terraform apply -auto-approve  |& sed 's/.*\[DEBUG\] provider.terraform-provider-//'
```
