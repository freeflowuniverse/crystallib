module qemu

import os
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.ui.console

@[heap]
pub struct VM {
pub mut:
	name           string
	status         VMStatus
	dir            string
	arch           string
	cpus           int
	memory         i64
	disk           i64
	ssh_local_port int
	// host_agent_pid  int [json: hostAgentPID]
	// driver_pid     int [json: driverPID]
	ssh_address string
	// qemu_home      string [json: QemuHome]
	identity_file string       @[json: IdentityFile]
	factory       &QemuFactory @[skip; str: skip]
}

pub enum VMStatus {
	unknown
	running
	stopped
}

@[params]
pub struct ActionArgs {
pub:
	force bool
}

pub fn (mut vm VM) load(args ActionArgs) ! {
	console.print_header('vm: ${vm.name} load')
	mut vm_system := vm.factory.vm_get(vm.name)!
	assert vm.name == vm_system.name

	vm.status = vm_system.status
	vm.dir = vm_system.dir
	vm.arch = vm_system.arch
	vm.cpus = vm_system.cpus
	vm.memory = vm_system.memory
	vm.disk = vm_system.disk
	vm.ssh_local_port = vm_system.ssh_local_port
	vm.ssh_address = vm_system.ssh_address
	vm.identity_file = vm_system.identity_file
}

pub fn (mut vm VM) stop(args ActionArgs) ! {
	console.print_header('vm: ${vm.name} stop')
	cmd := 'qemuctl stop ${vm.name} -f'
	res := os.execute(cmd)
	if res.exit_code > 0 {
		return error('could not stop qemu vm.\n${res}')
	}
	vm.load()!
}

pub fn (mut vm VM) start(args ActionArgs) ! {
	console.print_header('vm: ${vm.name} start')
	cmd := 'qemuctl start ${vm.name}'
	res := os.execute(cmd)
	if res.exit_code > 0 {
		return error('could not start qemu vm.\n${res}')
	}
	vm.load()!
}

pub fn (mut vm VM) delete(args ActionArgs) ! {
	console.print_header('vm: ${vm.name} delete')
	vm.stop()!
	vm.factory.vm_delete(vm.name)!
}

pub fn (mut vm VM) install_crystal() ! {
	console.print_header('vm: ${vm.name} install crystal')
	if vm.status == .stopped {
		vm.start()!
	}
	localport := vm.ssh_local_port
	if localport == 0 {
		return error('port should never be 0, means vm not started.\n${vm}')
	}
	mut b := builder.bootstrapper()
	mut address := 'root@localhost:${localport}'
	b.run(name: vm.name, addr: address, debug: true)!
}
