module terraform
import os

[heap]
struct TFNet {
pub mut:	
	description string
	tfgrid_node_ids []int	
	name string
	iprange string = "10.1.0.0/16"
}


//will put under ~/git3/terraform/$name
fn (mut net TFNet) execute(mut deployment &TerraformDeployment)? {
	mut tff := get()?
	// mut tfscript := TF_NET
	if net.tfgrid_node_ids.len==0{
		return error("tfgrid_node_ids cannot be empty in $net")
	}

	nodeids := net.tfgrid_node_ids.map(it.str()).join(",")

	net.name = deployment.guid+"_"+deployment.name //needs to be globally unique

	tfscript := $tmpl("templates/net.tf")


	dir_path := "${deployment.path}/net_${deployment.name}"
	if ! os.exists(dir_path){
		os.mkdir_all(dir_path)?
	}
	os.write_file("$dir_path/net.tf",tfscript)?

	tff.tf_execute(dir_path)?
}