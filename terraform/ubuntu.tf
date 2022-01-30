 terraform {
  required_providers {
    grid = {
      source = "threefoldtech/grid"
    }
  }
}

variable "emailaddr" {
  type = string
}

variable "mnemonics" {
  type = string
}

variable "secret" {
  type = string
}

provider "grid" {
    mnemonics = var.mnemonics
    network = "test" # or test to use testnet
}

resource "grid_network" "net1" {
    nodes = [32]
    ip_range = "10.1.0.0/16"
    name = "kds_network"
    description = "newer network"
    add_wg_access = true
}

resource "grid_deployment" "d1" {
  node = 32
  network_name = grid_network.net1.name
  ip_range = lookup(grid_network.net1.nodes_ip_range, 32, "")
  disks {
    name = "root"
    size = 20
    description = "root vol"
  }
  disks {
    name = "var"
    size = 100
    description = "var"
  }
  vms {
    name = "vm1"
    flist = "https://hub.grid.tf/samehabouelsaad.3bot/abouelsaad-grid3_ubuntu20.04-latest.flist"
    # flist = "https://hub.grid.tf/omarabdul3ziz.3bot/omarabdul3ziz-ubuntu-20.04-devenv.flist"
    entrypoint = "/init.sh"
    # entrypoint = "/start.sh"
    mounts {
        disk_name = "root"
        mount_point = "/root"
    }  
    mounts {
        disk_name = "var"
        mount_point = "/var"
    }        
    cpu = 8
    memory = 8000
    rootfs_size = 10000
    env_vars = {
      SSH_KEY ="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/9RNGKRjHvViunSOXhBF7EumrWvmqAAVJSrfGdLaVasgaYK6tkTRDzpZNplh3Tk1aowneXnZffygzIIZ82FWQYBo04IBWwFDOsCawjVbuAfcd9ZslYEYB3QnxV6ogQ4rvXnJ7IHgm3E3SZvt2l45WIyFn6ZKuFifK1aXhZkxHIPf31q68R2idJ764EsfqXfaf3q8H3u4G0NjfWmdPm9nwf/RJDZO+KYFLQ9wXeqRn6u/mRx+u7UD+Uo0xgjRQk1m8V+KuLAmqAosFdlAq0pBO8lEBpSebYdvRWxpM0QSdNrYQcMLVRX7IehizyTt+5sYYbp6f11WWcxLx0QDsUZ/J"
    }
    planetary = true
  }

  connection {
    type     = "ssh"
    user     = "root"
    agent    = true
    host     = grid_deployment.d1.vms[0].ygg_ip
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "mkdir -p /tmp/${var.emailaddr}"
  #   ]
  # }

  provisioner "file" {
    source      = "scripts"
    destination = "/tmp"
  }


  provisioner "remote-exec" {
    inline = [
      "apt update && apt upgrade -y && apt install mc curl git tmux pen htop sudo net-tools screen -y",
      # "yes | unminimize",
      "curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/install.sh > /tmp/install.sh", 
      #make sure to add your own email
      "git config --global user.email '${var.emailaddr}'",
      #do ipv6 from 8000 to 8080 and 8001 to 9998, the local ones are ipv4
      "pen -d :::8000 127.0.0.1:8080",
      "pen -d :::8001 127.0.0.1:9998",
      "echo ${var.secret} > /tmp/secret",
      "echo ${var.emailaddr} > /tmp/emailaddr",
      # "apt-get autoremove && apt-get clean"
      # "bash /tmp/install.sh",
      # "bash /tmp/scripts/install_docker.sh"
      # "bash /tmp/scripts/install_codeserver.sh"
      # "bash /tmp/scripts/install_chroot.sh"
    ]
  }
}


output "node1_zmachine1_ip" {
    value = grid_deployment.d1.vms[0].ip
}

output "ygg_ip" {
    value = grid_deployment.d1.vms[0].ygg_ip
}

