module tfrobot

import json
import os
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal

const tfrobot_dir = '${os.home_dir()}/hero/tfrobot' // path to tfrobot dir in fs

pub struct DeployConfig {
	name string
	mnemonic string  @[required]
	network Network @[required]
	node_groups []NodeGroup @[required]
	vms []VMConfig @[required]
	ssh_keys map[string]string
}

pub struct NodeGroup {
	name string
	nodes_count int @[required]
	free_cpu int @[required]// number of logical cores
	free_mru int @[required]// amount of memory in MB
	free_ssd int  // amount of ssd storage in GB
	free_hdd int // amount of hdd storage in GB
	dedicated bool // are nodes dedicated
	public_ip4 bool 
	public_ip6 bool 
	certified bool // should the nodes be certified(if false the nodes could be certified of diyed) 
	region string //region could be the name of the continents the nodes are located in (africa, americas, antarctic, antarctic ocean, asia, europe, oceania, polar)
}

pub struct VMConfig {
pub:
	name      string @[required]
	vms_count int @[required]
	node_group string @[required]
	cpu int @[required]
	mem int @[required]
	public_ip4 bool 
	public_ip6 bool 
	flist string @[required]
	entry_point string @[required]
	root_size int
	ssh_key   string @[required]
}

// pub struct SSHKey

pub struct DeployResult {
	ok map[string][]VMOutput
	error map[string]string
}

pub struct VMOutput {
	name   string @[required; json: 'Name']
	public_ip4    string @[required; json: 'PublicIP4']
	public_ip6    string @[required; json: 'PublicIP6']
	ygg_ip  string @[required; json: 'YggIP']
	ip     string @[required; json: 'IP']
	mounts []Mount @[required; json: 'Mounts']
}

pub struct Mount {
	disk_name string
	mount_point string
}

pub fn (mut robot TFRobot) deploy(config DeployConfig) !DeployResult {

	mut config_file := pathlib.get_file(
		path: '${tfrobot_dir}/deployments/${config.name}_config.json'
		create: true
	)!
	mut output_file := pathlib.get_file(
		path: '${tfrobot_dir}/deployments/${config.name}_output.json'
		create: false
	)!
	
	config_file.write(json.encode(config))!
	result := osal.exec(
		cmd:'tfrobot deploy -c ${config_file.path} -o ${output_file.path}', 
		stdout:true
	)!
	output := output_file.read()!
	return json.decode(DeployResult, output)
}

fn check_deploy_config(config DeployConfig) ! {
	vms := config.vms.filter(it.node_group !in config.node_groups.map(it.name))
	if vms.len > 0 {
		error_msgs := vms.map('Node group: `${it.node_group}` for VM: `${it.name}`')
		return error('${error_msgs.join(',')} not found.')
	}

	unknown_keys := config.vms.filter(it.ssh_key !in config.ssh_keys).map(it.ssh_key)
	if unknown_keys.len > 0 {
		return error('SSH Keys [${unknown_keys.join(',')}] not found.')
	}
}