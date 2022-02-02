module terraform
import os

const TF_VM = '
 terraform {
  required_providers {
    grid = {
      source = "threefoldtech/grid"
    }
  }
}

provider "grid" {
    mnemonics = "@MNEMONIC"
    network = "test" # or test to use testnet
}

resource "grid_deployment" "d1" {
  node = @NODE_ID
  network_name = @NETNAME
  ip_range = @IPRANGE
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
    name = "@VMNAME"
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
      SSH_KEY ="@SSHKEY"
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


'



[heap]
struct TFVM {
pub:
	description 	string
	tfgrid_node_id 	int
	name 			string
}


//will put under ~/git3/terraform/$name
fn (mut vm TFVM) execute(mut deployment &TerraformDeployment)? {
	mut tff := get()?
	mut tfscript := TF_VM
	tfscript = tfscript.replace("@MNEMONIC",deployment.mnemonic)
	tfscript = tfscript.replace("@NODE_ID",vm.tfgrid_node_id.str())
	tfscript = tfscript.replace("@NAME",vm.name)
	tfscript = tfscript.replace("@DESCRIPTION",vm.description)
	tfscript = tfscript.replace("@NETNAME",deployment.network.name)
	tfscript = tfscript.replace("@IPRANGE",deployment.network.iprange)
	tfscript = tfscript.replace("@SSHKEY",deployment.sshkey)
	dir_path := "${deployment.path}/vm_${vm.name}"
	if ! os.exists(dir_path){
		os.mkdir_all(dir_path)?
	}
	os.write_file("$dir_path/vm.tf",tfscript)?
	//apply terraform
	tff.tf_execute(dir_path)?
}