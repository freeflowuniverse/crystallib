module lima
import os
import raw
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.ui.console

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
    ssh_address    string
    // lima_home      string [json: LimaHome]
    identity_file  string [json: IdentityFile]
}

pub enum VMStatus{
	unknown
	running
	stopped
}

pub fn vm_get(name string) !VM{
    for vm in vm_get_all()!{
        if vm.name.to_lower() == name.to_lower(){
            return vm
        }
    }
    return error("Couldn't find vm with name: ${name}")
}

pub fn vm_exists(name string) !bool{
    for vm in vm_list()!{
        if vm.to_lower() == name.to_lower(){
            return true
        }
    }
    return false
}


pub fn vm_stop_all() !{
    for mut vm in vm_get_all()!{
        vm.stop()!
    }
}

pub fn vm_delete_all() !{
    for mut vm in vm_get_all()!{
        vm.delete()!
    }
}

pub fn vm_list() ![]string{	
	cmd := "limactl list -f '{{.Name}}'"
	res := os.execute(cmd)
	mut vms:=[]string{}
	if res.exit_code > 0 {
		return error('could not stop lima vm.\n${res}')
	}	
    for line in res.output.split_into_lines(){
        if line.trim_space()==""{
            continue
        }
        vms<<line.trim_space()
    }
	return vms
}

pub fn vm_get_all() ![]VM{
	mut vms:=[]VM{}
	for vm in raw.list()!{
		// println(vm)
		mut vm2:=VM{
			name:vm.name
			dir:vm.dir
			arch:vm.arch
			cpus:vm.cpus
			memory:vm.memory/1000000
			disk:vm.disk/1000000
			ssh_local_port:vm.ssh_local_port
			ssh_address:vm.ssh_address
			identity_file:vm.identity_file
		}
		match vm.status{
			"Running"{
				vm2.status=.running
			}"Stopped"{
				vm2.status=.stopped			
			}else{
				println(vm.status)
				panic("unknown status")
			}
		}
		vms<<vm2
	}
	return vms
}



[params]
pub struct ActionArgs{
pub:
    force bool
}

pub fn (mut vm VM) load(args ActionArgs) !{
	console.print_header("vm: ${vm.name} load")
	mut vm_system:=vm_get(vm.name)!
	assert vm.name==vm_system.name

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

pub fn (mut vm VM) stop(args ActionArgs) !{
	console.print_header("vm: ${vm.name} stop")
	cmd := 'limactl stop ${vm.name} -f'
	res := os.execute(cmd)
	if res.exit_code > 0 {
		return error('could not stop lima vm.\n${res}')
	}
	vm.load()!
}

pub fn (mut vm VM) start(args ActionArgs) !{
	console.print_header("vm: ${vm.name} start")
	cmd := 'limactl start ${vm.name}'
	res := os.execute(cmd)
	if res.exit_code > 0 {
		return error('could not start lima vm.\n${res}')
	}
	vm.load()!
}

pub fn (mut vm VM) delete(args ActionArgs) !{
	console.print_header("vm: ${vm.name} delete")
	vm.stop()!
	vm_delete(vm.name)!
}


pub fn vm_stop(name string) !{	
	console.print_header("vm: ${name} stop")
	cmd := 'limactl stop ${name}'
	os.execute(cmd)
	// if res.exit_code > 0 {
	// 	return error('could not delete lima vm.\n${res}')
	// }
	cmd2 := 'limactl stop ${name} -f'
	os.execute(cmd2)

}


pub fn vm_delete(name string) !{	
	console.print_header("vm: ${name} delete")	
	vm_stop(name)!
	cmd := 'limactl delete ${name} -f'
	res := os.execute(cmd)
	if res.exit_code > 0 {
		return error('could not delete lima vm.\n${res}')
	}
}



pub fn (mut vm VM) install_crystal() !{
	console.print_header("vm: ${vm.name} install crystal")
	if vm.status==.stopped{
		vm.start()!
	}
	localport:=vm.ssh_local_port
	if localport == 0{
		return error("port should never be 0, means vm not started.\n$vm")
	}
	mut b := builder.bootstrapper()
	mut address:='root@localhost:${localport}'
	b.run(name:vm.name,addr:address,debug:true)!
}

