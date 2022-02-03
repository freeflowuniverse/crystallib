
resource "grid_deployment" "d1" {
  node = @vm.tfgrid_node_id
  network_name = "@deployment.network.name"
  ip_range = "@deployment.network.iprange"
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
    name = "@vm.name"
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
    # rootfs_size = 10000
    env_vars = {
      SSH_KEY ="@deployment.sshkey"
    }
    planetary = true
  }

  connection {
    type     = "ssh"
    user     = "root"
    agent    = true
    host     = grid_deployment.d1.vms[0].ygg_ip
  }

}


output "node1_zmachine1_ip" {
    value = grid_deployment.d1.vms[0].ip
}

output "ygg_ip" {
    value = grid_deployment.d1.vms[0].ygg_ip
}
