module tfrobot

import os
import arrays
import freeflowuniverse.crystallib.core.pathlib

pub struct Job {
pub:
	name string
	network Network
	mneumonic string @[required]
pub mut:
	ssh_keys map[string]string
	deployments []Deployment
	vms map[string]VirtualMachine
}

// Deployment is an instruction to deploy a quantity of VMs with a given configuration
pub struct Deployment {
pub:
	config VMConfig
	quantity int
}

pub struct VMConfig {
pub:
	name string
	region string
	nrcores int
	flist string
	memory_mb int
	memory_gb int //todo
	ssh_key string
	pub_ip bool
}

pub enum Network {
	main
	dev
	test
}

pub fn (mut r TFRobot) job_new(job Job) !Job {
	r.jobs[job.name] = job
	return job
}

pub fn (mut j Job) deploy_vms(config VMConfig, quantity int) {
	j.deployments << Deployment{config: config, quantity: quantity}
}

pub fn (mut j Job) run() ! {
	if j.deployments.len == 0 {
		return error('Nothing to deploy.')
	}
	if j.ssh_keys.keys().len == 0 {
		return error('Job requires at least one ssh key.')
	}

	os.mkdir_all('~/hero/tfrobot/jobs')!
	ymlfile := pathlib.get_file(
		path: '${os.home_dir()}/hero/tfrobot/jobs/${j.name}.yaml', 
		create: true
	)!
	config := $tmpl('./templates/config.yaml')
	pathlib.template_write(config, ymlfile.path, true)!
	result := os.execute_opt('tfrobot -c ${ymlfile.path}')!
	
	vms := parse_output(result.output)!
	for vm in vms {
		j.vms[vm.name] = vm
	}
}

pub fn (j Job) vm_get(name string) ?VirtualMachine {	
	if name !in j.vms {
		return none
	}
	return j.vms[name]
}

pub fn (mut j Job) add_ssh_key(name string, key string) {
	j.ssh_keys[name] = key
}

// parse_output parses the output of the tfrobot cli command
fn parse_output(output string) ![]VirtualMachine {
	if output.contains('error:') {return error('TFRobot CLI Error, output:\n${output}')}
	out_str_split := output.split('\nok:\n')
	if out_str_split.len == 0 {return error('error parsing output')}
	to_parse := out_str_split[1]
	
	vms_lst := arrays.chunk(to_parse.all_after('[').trim_string_right('\n]\n').split_into_lines(), 6)
	vms := vms_lst.map(VirtualMachine{
		name: it[0].trim_space().trim_string_left('name: ')
		ip4: it[1].trim_string_left('publicip4: ')
		ip6: it[2].trim_string_left('publicip6: ')
		yggip: it[3].trim_string_left('yggip: ')
		ip: it[4].trim_string_left('ip: ')
		mounts: []
	})
	return vms
}