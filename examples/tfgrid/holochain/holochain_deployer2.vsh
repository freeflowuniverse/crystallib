#!/usr/bin/env v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.tfrobot
import freeflowuniverse.crystallib.ui.console

console.print_header("Deploy test of vmachines on TFGrid using TFRobot.")

mut bot := tfrobot.new()!

mut deploy_config := tfrobot.DeployConfig{
	name: 'holotest'
	network: .main
	debug: true
	node_groups: [
		tfrobot.NodeGroup{
			name: 'holotestgroup'
			nodes_count: 4
			free_cpu: 4
			free_mru: 8
			free_ssd: 100
		},
	]
	vms: [
		tfrobot.VMConfig{
			name: 'test'
			vms_count: 4
			cpu: 4
			mem: 4
			entry_point: '/sbin/zinit init'
			flist: 'https://hub.grid.tf/mariobassem1.3bot/threefolddev-holochain-latest.flist'
			env_vars: {
				'CODE_SERVER_PASSWORD': 'mypass'
			}
			public_ip4: false
			root_size: 50
			planetary: true
		},
	]
}

//ssh-key is not specified, first key will be chosen

//DEAL WITH SSH KEYS
tfrobot.sshagent_keys_add(mut deploy_config)!
console.print_header("nr of ssh keys in ssh-agent:${deploy_config.ssh_keys.len}")

res := bot.deploy(deploy_config)!

// vm.ssh_interactive(ssh_key_path.path)! //NO CLEAN

// job.deploy_vms(vm_config, 1)
// output := job.run()!
// println('output:\n${output}')
// vm := job.vm_get('holo_vm2')?
// vm := tfrobot.VirtualMachine{}
// vm.ssh_interactive()!
// vm.code_server()!

// console.print_debug_title("MYVM", vm.str())
// env:={"tfrobot":"ourmiceliumipaddr"}
