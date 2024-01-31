module tfrobot

import os
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.osal

// VirtualMachine represents the VM info outputted by tfrobot
pub struct VirtualMachine {
	name   string
	ip4    string
	ip6    string
	yggip  string
	ip     string
	mounts []string
}

pub fn (vm VirtualMachine) ssh_interactive() ! {
	// b := builder.new()
	// node := b.node_new(ipaddr:"root@${vm.ip4}")!
	// node.exec_interactive('${homedir}/hero/bin/install.sh')!
	osal.execute_interactive('ssh root@${vm.ip4.all_before('/')}')! //TODO: see if its working in builders
}


pub fn (vm VirtualMachine) node() !builder.Node {
	b := builder.new()
	node := b.node_new(ipaddr:"root@${vm.ip4}")!
	return node
	// node.exec_interactive('${homedir}/hero/bin/install.sh')!
	// osal.execute_interactive('ssh root@${vm.ip4.all_before('/')}')!
}
