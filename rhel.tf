terraform {
 required_version = ">= 1.0.9"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.6.11"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://root@9.152.91.155/system"
}

variable "vm_machines" {
  type = list(string)
  #default = ["fw171", "fw172", "fw173"]
  default = ["fw172"]
}

resource "libvirt_volume" "rhel" {
  name   = "${var.vm_machines[count.index]}.qcow2"
  count  = length(var.vm_machines)
  pool   = "images"
  source = "http://9.152.91.156/rhel-guest-image-8.4-992.s390x.qcow2"
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
          name = "commoninit.iso"
          pool = "images"
          user_data = "${data.template_file.user_data.rendered}"
          network_config = "${data.template_file.network_config.rendered}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/cloud_init.cfg")}"
}

data "template_file" "network_config" {
  template = "${file("${path.module}/network_config.cfg")}"
}


resource "libvirt_domain" "rhel" {
  count = length(var.vm_machines)
  name = var.vm_machines[count.index]
  memory = "1024"
  vcpu = 1

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

 xml {
    xslt = file("${path.module}/nodes-adjust.xslt")
  }

  network_interface {
     network_name = "bridged-network"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
      type        = "pty"
      target_type = "virtio"
      target_port = "1"
  }

  disk {
       volume_id = libvirt_volume.rhel[count.index].id
  }
  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = "true"
  }
}
