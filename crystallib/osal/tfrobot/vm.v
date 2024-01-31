module tfrobot

import os
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.osal
import time

// VirtualMachine represents the VM info outputted by tfrobot
pub struct VirtualMachine {
	name   string
	ip4    string
	ip6    string
	yggip  string
	ip     string
	mounts []string
}

pub fn (vm VMOutput) ssh_interactive(key_path string) ! {
	// b := builder.new()
	// node := b.node_new(ipaddr:"root@${vm.ip4}")!
	// node.exec_interactive('${homedir}/hero/bin/install.sh')!
	time.sleep(15*time.second)
	osal.execute_interactive('ssh -i ${key_path} root@${vm.public_ip4.all_before("/")}')!
}
