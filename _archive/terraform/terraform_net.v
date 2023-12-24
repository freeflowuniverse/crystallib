module terraform

import os

@[heap]
struct TFNet {
pub mut:
	description     string
	tfgrid_node_ids []int
	name            string
	iprange         string = '10.3.0.0/16'
}

fn (mut net TFNet) avoid_duplicate() {
	// TODO
	// Avoid duplicate id in tfgrid_node_ids
	// Sort + iterate should be easy, there is nothing builtin to do it, checked
}

// will put under ~/git3/terraform/$name
fn (mut net TFNet) write(mut deployment TerraformDeployment) ? {
	mut tff := get()?
	// mut tfscript := TF_NET
	if net.tfgrid_node_ids.len == 0 {
		return error('tfgrid_node_ids cannot be empty in ${net}')
	}

	nodeids := net.tfgrid_node_ids.map(it.str()).join(',')

	net.name = deployment.guid + '_' + deployment.name // needs to be globally unique

	tfscript := $tmpl('templates/net.tf')
	os.write_file('${deployment.path}/net.tf', tfscript)?
}
