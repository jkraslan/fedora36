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
  uri = "qemu+ssh://root@9.152.56.12/system"
}

variable "vm_machines" {
  type = list(string)
  default = ["test"]
}

variable "hostname" {
  type = string
  default = "hasox"
}

resource "libvirt_volume" "rhel" {
  name   = "${var.hostname}.qcow2"
  pool   = "images"
  source = "https://ftp.upjs.sk/pub/fedora/linux/releases/36/Cloud/x86_64/images/Fedora-Cloud-Base-36-1.5.x86_64.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "resized" {
  name = "${var.hostname}.qcow2"
  base_volume_id = libvirt_volume.rhel.id
  pool = "images"
  size = 50*1024*1024*1024
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
  memory = "2048"
  vcpu = 2

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  network_interface {
     network_name = "default"
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
       volume_id = libvirt_volume.rhel.id
  }
  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = "true"
  }
}
