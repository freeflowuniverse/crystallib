module terraform
import os
import texttools


[heap]
struct TFVM {
pub mut:
	description 	string
	tfgrid_node_id 	int
	name 			string
  memory    		int
  public_ip 		bool
//   tf_deployment      &TerraformDeployment
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
	memory    		int
	public_ip 		bool
	nodeid			int
}




//will put under ~/git3/terraform/$name
fn (mut vm TFVM) write(mut deployment &TerraformDeployment)? {
	mut tff := get()?
	disks := vm.disks
	public_ip := vm.public_ip
	tfscript := $tmpl("templates/ubuntu.tf")
	os.write_file("${deployment.path}/vm_${vm.name}.tf",tfscript)?
}



//execute all available terraform objects
pub fn (mut tfd TerraformDeployment) vm_ubuntu_add(args VMArgs) TFVM {	
	mut vm := TFVM{
		name:args.name,
		description:args.description,
		tfgrid_node_id:args.nodeid,
		memory: args.memory
		public_ip: args.public_ip
		// tf_deployment: &tfd
    }	
  	tfd.vms << vm
	return vm
}

pub fn (mut vm TFVM) disk_add(size_gb int, mountpoint string) {
	mut disk := TFVMDisk{size_gb: size_gb, mountpoint:mountpoint}
	disk.name = texttools.name_fix(disk.mountpoint.replace("/","_"))
	vm.disks << disk
}
