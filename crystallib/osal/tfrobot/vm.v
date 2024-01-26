module tfrobot

import os

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
	os.execvp('ssh', ['root@${vm.ip4}'])!
}
