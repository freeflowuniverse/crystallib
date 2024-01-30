#!/usr/bin/env v -w -enable-globals run

import freeflowuniverse.crystallib.osal.tfrobot
import freeflowuniverse.crystallib.osal.sshagent
import freeflowuniverse.crystallib.ui.console
// import toml
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
mut job:= bot.job_new(
	name:"my_holo_deployment"
	network: .main
	mneumonic: mnemonic
)!
mut ssha := sshagent.new()!
if ssha.keys.len==0{
	println("can't find ssh keys in agent, please load")
	exit(1)
}
sshkey:=ssha.keys[0].pubkey

// job.add_ssh_key('my_key', env.value('SSH_KEY').string())

job.add_ssh_key('my_key',sshkey)

vm_config := tfrobot.VMConfig{
	name: 'holo_vm',
	region:"europe",
	nrcores:1,
	memory_mb:256,
	ssh_key: 'my_key',
	flist: "https://hub.grid.tf/mariobassem1.3bot/threefolddev-holochain-latest.flist"
	pub_ip: true
}

job.deploy_vms(vm_config, 3)
job.run()!
vm:=job.vm_get("holo_vm2")?
// vm := tfrobot.VirtualMachine{}
vm.ssh_interactive()!
// vm.code_server()!

// console.print_debug_title("MYVM", vm.str())
// env:={"tfrobot":"ourmiceliumipaddr"}
