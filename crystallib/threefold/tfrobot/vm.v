module tfrobot

// import os
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import time

// VirtualMachine represents the VM info outputted by tfrobot
pub struct VirtualMachine {
	name   string
	ip4    string
	ip6    string
	yggip  string
	ip     string
	// mounts []string
}

// pub fn (vm VMOutput) ssh_interactive(key_path string) ! {
// 	// b := builder.new()
// 	// node := b.node_new(ipaddr:"root@${vm.ip4}")!
// 	// node.exec_interactive('${homedir}/hero/bin/install.sh')!
// 	// time.sleep(15 * time.second)
// 	if vm.public_ip4 != '' {
// 		osal.execute_interactive('ssh -i ${key_path} root@${vm.public_ip4.all_before('/')}')!
// 	} else if vm.planetary_ip != '' {
// 		osal.execute_interactive('ssh -i ${key_path} root@${vm.planetary_ip}')!
// 	} else {
// 		return error('no public nor planetary ip available to use')
// 	}
// }


[params]
pub struct NodeArgs {
pub mut:
	ip4    bool = true
	ip6    bool = true
	planetary  bool = true
	timeout int = 120 //timeout in sec
}


//return ssh node (can be used to do actions remotely)
//will check all available channels till it can ssh into the node
pub fn (vm VMOutput) node(args NodeArgs) !&builder.Node {
	mut b:=builder.new()!
	start_time := time.now().unix_time_milli()
	mut run_time := 0.0
	for true {
		if args.ip4 && vm.public_ip4.len>0 {
			console.print_debug("test ipv4 to: ${vm.public_ip4} for ${vm.name}")
			if osal.tcp_port_test(address:vm.public_ip4,port:22, timeout:2000) {
				console.print_debug("SSH port test ok")
				return b.node_new(ipaddr:"root@${vm.public_ip4}")!
			}
		}
		if args.ip6 && vm.public_ip6.len>0 {
			console.print_debug("test ipv6 to: ${vm.public_ip6} for ${vm.name}")
			if osal.tcp_port_test(address:vm.public_ip6, port:22, timeout:2000) {				
				console.print_debug("SSH port test ok")
				return b.node_new(ipaddr:"root@[${vm.public_ip6}]")!
			}
		}
		if args.planetary && vm.planetary_ip.len>0 {
			console.print_debug("test planetary to: ${vm.planetary_ip} for ${vm.name}")
			if osal.tcp_port_test(address:vm.planetary_ip, port:22, timeout:2000) {
				console.print_debug("SSH port test ok")
				return b.node_new(ipaddr:"root@[${vm.planetary_ip}]")!
			}
		}
		run_time = time.now().unix_time_milli()
		if run_time > start_time + args.timeout*1000 {
			break
		}
		time.sleep(100 * time.millisecond)
	}
	return error("couldn't connect to node, probably timeout.")
}