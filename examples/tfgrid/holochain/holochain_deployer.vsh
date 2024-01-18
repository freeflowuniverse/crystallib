#!/usr/bin/env v -w -enable-globals run

import freeflowuniverse.crystallib.osal.tfrobot
import freeflowuniverse.crystallib.ui.console
import os

mut tfrobot:=tfrobot.new()!

flist:="https://hub.grid.tf/mariobassem1.3bot/threefolddev-holochain-latest.flist"

mut job:=tfrobot.job_new(name:"my_holo_deployment")!

sshkey:='
'

env:={"tfrobot":"ourmiceliumipaddr"}

for i in [0..10]{
	name:="holo_${i}"
	job.vm_add(name:name,region:"europe",nrcores:8,memory_gb:4,
		sshkey:sshkey,env:env,pubip:true)

}

job.run()!

vm:=job.vm_get(name:"holo_5")

vm.ssh_interactive()!
vm.code_server()!

// console.print_debug_title("MYVM", vm.str())