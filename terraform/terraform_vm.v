module terraform
import os
import texttools
import threefoldtech.vgrid.gridproxy
import rand


[heap]
struct TFVM {
pub mut:
	description 	string
	tfgrid_node_id 	int
	name 			string
	memory_gb    	f32
	public_ip 		bool
	disks 			[]TFVMDisk
}

[heap]
struct TFVMDisk {
pub mut:
	name 		  	string
	size_gb 		int
	description 	string
	mountpoint 		string
}


pub struct VMArgs {
pub:
	description 	string
	tfgrid_node_id 	int
	name 			string
	memory_gb    	f32
	public_ip 		bool
	nodeid			int
	nodes			[]gridproxy.NodeInfo
}




//will put under ~/git3/terraform/$name
fn (mut vm TFVM) write(mut deployment &TerraformDeployment)? {
	mut tff := get()?
	disks := vm.disks
	public_ip := vm.public_ip
	tfscript := $tmpl("templates/ubuntu.tf")
	os.write_file("${deployment.path}/vm_${vm.name}.tf",tfscript)?
}

//walk over all nodes available find a random one
fn (mut vm TFVM) node_finder (mut deployment &TerraformDeployment, nodes []gridproxy.NodeInfo) ? {

	mut gp := deployment.gridproxy()

	mut res := []gridproxy.NodeInfo{}

	if vm.tfgrid_node_id>0 {

		//retrieve node, should give error if not right one
		node := gp.node_info(vm.tfgrid_node_id)?

		mru_available_gb := node.available_resources.mru - node.used_resources.mru
		if vm.memory_gb > mru_available_gb{
			return error("VM $vm needs more memory than available in $node")
		}

		if vm.public_ip && node.nr_pub_ipv4 == 0 {
			return error("VM $vm public ip address, is not available in $node")
		}

	}else if nodes.len>0 {
		for node in nodes{

			// cru_available_gb := node.available_resources.cru - node.used_resources.cru
			mru_available_gb := node.available_resources.mru - node.used_resources.mru
			// hru_available_gb := node.available_resources.hru - node.used_resources.hru
			// sru_available_gb := node.available_resources.sru - node.used_resources.sru

			if vm.memory_gb > mru_available_gb{
				continue
			}
			if vm.public_ip && node.nr_pub_ipv4 == 0 {
				continue
			}
			res << node
		}

		if res.len==0{
			return error("${gp.nodes_print(nodes)}\nVM $vm requirements cannot be found in available nodes.")
		}

		c := rand.int_in_range(0,res.len-1)?
		vm.tfgrid_node_id = nodes[c].id

		println("node selected: $vm.tfgrid_node_id")
	}else{
		return error("Cannot find node for vm:\n$vm")
	}

}


//execute all available terraform objects
pub fn (mut tfd TerraformDeployment) vm_ubuntu_add(args VMArgs) ?TFVM {
	mut vm := TFVM{
		name:args.name,
		description:args.description,
		tfgrid_node_id:args.nodeid,
		memory_gb: args.memory_gb
		public_ip: args.public_ip
    }
	vm.node_finder (mut tfd, args.nodes)?
	tfd.vms << vm
	tfd.network.tfgrid_node_ids << vm.tfgrid_node_id
	return vm
}

pub fn (mut vm TFVM) disk_add(size_gb int, mountpoint string) {
	mut disk := TFVMDisk{size_gb: size_gb, mountpoint:mountpoint}
	disk.name = texttools.name_fix(disk.mountpoint.replace("/","_"))
	vm.disks << disk
}
