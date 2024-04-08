module cloudhypervisor

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.installers.virt.cloudhypervisor as cloudhypervisorinstaller
import os

@[heap]
pub struct CloudHypervisorFactory {
pub mut:
	debug bool
}

pub fn new() !CloudHypervisorFactory {
	cloudhypervisorinstaller.install()!
	return CloudHypervisorFactory{}
}

// pub fn (mut lf CloudHypervisorFactory) vm_get_all() ![]VM {
// 	mut vms := []VM{}
// 	for vm in raw.list()! {
// 		// println(vm)
// 		mut vm2 := VM{
// 			name: vm.name
// 			dir: vm.dir
// 			arch: vm.arch
// 			cpus: vm.cpus
// 			memory: vm.memory / 1000000
// 			disk: vm.disk / 1000000
// 			ssh_local_port: vm.ssh_local_port
// 			ssh_address: vm.ssh_address
// 			identity_file: vm.identity_file
// 			factory: &lf
// 		}
// 		match vm.status {
// 			'Running' {
// 				vm2.status = .running
// 			}
// 			'Stopped' {
// 				vm2.status = .stopped
// 			}
// 			else {
// 				println(vm.status)
// 				panic('unknown status')
// 			}
// 		}
// 		vms << vm2
// 	}
// 	return vms
// }

// pub fn (mut lf CloudHypervisorFactory) vm_get(name string) !VM {
// 	for vm in lf.vm_get_all()! {
// 		if vm.name.to_lower() == name.to_lower() {
// 			return vm
// 		}
// 	}
// 	return error("Couldn't find vm with name: ${name}")
// }

// pub fn (mut lf CloudHypervisorFactory) vm_exists(name string) !bool {
// 	for vm in lf.vm_list()! {
// 		if vm.to_lower() == name.to_lower() {
// 			return true
// 		}
// 	}
// 	return false
// }

// pub fn (mut lf CloudHypervisorFactory) vm_stop_all() ! {
// 	for mut vm in lf.vm_get_all()! {
// 		vm.stop()!
// 	}
// }

// pub fn (mut lf CloudHypervisorFactory) vm_delete_all() ! {
// 	for mut vm in lf.vm_get_all()! {
// 		vm.delete()!
// 	}
// }

// pub fn (mut lf CloudHypervisorFactory) vm_list() ![]string {
// 	cmd := "qemuctl list -f '{{.Name}}'"
// 	res := os.execute(cmd)
// 	mut vms := []string{}
// 	if res.exit_code > 0 {
// 		return error('could not stop qemu vm.\n${res}')
// 	}
// 	for line in res.output.split_into_lines() {
// 		if line.trim_space() == '' {
// 			continue
// 		}
// 		vms << line.trim_space()
// 	}
// 	return vms
// }

// pub fn (mut lf CloudHypervisorFactory) vm_stop(name string) ! {
// 	console.print_header('vm: ${name} stop')
// 	cmd := 'qemuctl stop ${name}'
// 	os.execute(cmd)
// 	// if res.exit_code > 0 {
// 	// 	return error('could not delete qemu vm.\n${res}')
// 	// }
// 	cmd2 := 'qemuctl stop ${name} -f'
// 	os.execute(cmd2)
// }

// pub fn (mut lf CloudHypervisorFactory) vm_delete(name string) ! {
// 	console.print_header('vm: ${name} delete')
// 	lf.vm_stop(name)!
// 	cmd := 'qemuctl delete ${name} -f'
// 	res := os.execute(cmd)
// 	if res.exit_code > 0 {
// 		return error('could not delete qemu vm.\n${res}')
// 	}
// }
