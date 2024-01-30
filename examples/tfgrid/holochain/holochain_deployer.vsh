#!/usr/bin/env v -w -enable-globals run

import freeflowuniverse.crystallib.osal.tfrobot
import toml
import os

env := toml.parse_file(os.dir(@FILE) + '/.env')!

mut bot:=tfrobot.new()!

// configure TFRobot job
mut job:= bot.job_new(
	name:"my_holo_deployment"
	network: .main
	mneumonic: env.value('MNEUMONIC').string()
)!

job.add_ssh_key('my_key', env.value('SSH_KEY').string())

vm_config := tfrobot.VMConfig{
	name: 'holo_vm',
	region:"europe",
	nrcores:2,
	memory_mb:2048,
	ssh_key: 'my_key',
	flist: "https://hub.grid.tf/mariobassem1.3bot/threefolddev-holochain-latest.flist"
	pub_ip: true
}

job.deploy_vms(vm_config, 1)
job.run()!
vm:=job.vm_get("holo_vm2")?
// vm := tfrobot.VirtualMachine{}
vm.ssh_interactive()!
// vm.code_server()!

// console.print_debug_title("MYVM", vm.str())
// env:={"tfrobot":"ourmiceliumipaddr"}
