module terraform
import os


[heap]
struct TFVM {
pub:
	description 	string
	tfgrid_node_id 	int
	name 			string
}


//will put under ~/git3/terraform/$name
fn (mut vm TFVM) write(mut deployment &TerraformDeployment)? {
	mut tff := get()?
	tfscript := $tmpl("templates/ubuntu.tf")
	os.write_file("${deployment.path}/vm_${vm.name}.tf",tfscript)?
}


