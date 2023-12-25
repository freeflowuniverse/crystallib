module lima
import os
import raw

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
		println(vm)
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
				vm2.status=.running			
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

pub fn (mut vm VM) stop(args ActionArgs) !{
	cmd := 'limactl stop ${vm.name} -f'
	res := os.execute(cmd)
	if res.exit_code > 0 {
		return error('could not stop lima vm.\n${res}')
	}
}

pub fn (mut vm VM) start(args ActionArgs) !{
	cmd := 'limactl start ${vm.name}'
	res := os.execute(cmd)
	if res.exit_code > 0 {
		return error('could not start lima vm.\n${res}')
	}
}

pub fn (mut vm VM) delete(args ActionArgs) !{
	vm.stop()!
	vm_delete(vm.name)!
}


pub fn vm_stop(name string) !{	
	cmd := 'limactl stop ${name}'
	res := os.execute(cmd)
	// if res.exit_code > 0 {
	// 	return error('could not delete lima vm.\n${res}')
	// }
	cmd2 := 'limactl stop ${name} -f'
	res2 := os.execute(cmd2)

}


pub fn vm_delete(name string) !{	
	vm_stop(name)!
	cmd := 'limactl delete ${name} -f'
	res := os.execute(cmd)
	if res.exit_code > 0 {
		return error('could not delete lima vm.\n${res}')
	}
}
