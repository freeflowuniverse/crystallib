#!/usr/bin/env v -w -enable-globals run

import freeflowuniverse.crystallib.osal.tfrobot
import freeflowuniverse.crystallib.osal.sshagent
import toml
import os

// env := toml.parse_file(os.dir(@FILE) + '/.env')!


if 'TFGRID_MNEMONIC' !in os.environ() {
	println("Cannot continue, do 'export TFGRID_MNEMONIC=...' ")
	exit(1)
}
mnemonic := os.environ()['TFGRID_MNEMONIC'].trim_space()

println("robot new")
mut bot:=tfrobot.new()!

println("job new")
// configure TFRobot job
mut job := bot.job_new(
	name: 'my_holo_deployment'
	network: .main
	mneumonic: mnemonic
)!

if ssha.keys.len==0{
	println("can't find ssh keys in agent, please load")
	exit(1)
}

mut ssha := sshagent.new()!
for key in ssha.keys{
	job.add_ssh_key(key.name, key.keypub()!)	
}
// sshkey:=ssha.keys[0].keypub()!
// job.add_ssh_key('my_key', env.value('SSH_KEY').string())
// sshkey:="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIahWiRRm9cWAKktH9dndn3R45grKqzPC3mKX8IjGgH6 kristof@incubaid.com"
// job.add_ssh_key('my_key', sshkey)

vm_config := tfrobot.VMConfig{
	name: 'holo_vm'
	region: 'europe'
	nrcores: 4
	memory_gb: 8
	ssh_key: 'my_key'
	flist: 'https://hub.grid.tf/mariobassem1.3bot/threefolddev-holochain-latest.flist'
	pub_ip: true
	env_vars: {
		'CODE_SERVER_PASSWORD': 'mypass'
	}
}

job.deploy_vms(vm_config, 4)
job.run()!
vm := job.vm_get('holo_vm2')?

// vm.ssh_interactive()!

node:=vm.node()!

node.crystal_install()!

// vm.code_server()!

// console.print_debug_title("MYVM", vm.str())
// env:={"tfrobot":"ourmiceliumipaddr"}
