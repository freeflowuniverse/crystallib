#!/usr/bin/env v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.tfrobot
import freeflowuniverse.crystallib.osal.sshagent
import toml
import os

if 'TFGRID_MNEMONIC' !in os.environ() {
	println("Cannot continue, do 'export TFGRID_MNEMONIC=...' ")
	exit(1)
}
mnemonic := os.environ()['TFGRID_MNEMONIC'].trim_space()

mut ssh_keys := map[string]string{}
mut ssha := sshagent.new()!
if ssha.keys.len == 0{
	ssha.generate('test_key', '')!
}

for mut key in ssha.keys{
	ssh_keys[key.name] = key.keypub()!.trim('\n')
}

ssh_key_name := ssha.keys[0].name
ssh_key_path := ssha.keys[0].keypath()!

println('robot new')
mut bot := tfrobot.new()!

mut deploy_config := tfrobot.DeployConfig{
	name: 'test'
	mnemonic: mnemonic
	network: .main
	node_groups: [
		tfrobot.NodeGroup{
			name: 'test_group'
			nodes_count: 1
			free_cpu: 4
			free_mru: 8
			free_ssd: 30
		},
	]
	vms: [
		tfrobot.VMConfig{
			name: 'test'
			vms_count: 1
			cpu: 4
			mem: 8
			node_group: 'test_group'
			ssh_key: ssh_key_name
			entry_point: '/sbin/zinit init'
			flist: 'https://hub.grid.tf/mariobassem1.3bot/threefolddev-holochain-latest.flist'
			env_vars: {
				'CODE_SERVER_PASSWORD': 'mypass'
			}
			public_ip4: false
			root_size: 30
			planetary: true
		},
	]
	ssh_keys: ssh_keys
}

res := bot.deploy(deploy_config)!

vm := res.ok['test_group'][0]

// vm.ssh_interactive(ssh_key_path.path)! //NO CLEAN

// println("job new")
// // configure TFRobot job
// mut job := bot.job_new(
// 	name: 'my_holo_deployment'
// 	network: .dev
// 	mneumonic: mnemonic
// )!

// mut ssha := sshagent.new()!
// if ssha.keys.len==0{
// 	println("can't find ssh keys in agent, please load")
// 	exit(1)
// }
// sshkey:=ssha.keys[0].keypub()!
// sshkey:="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCQi7Qp0fs4WowSBQJonYHNWNJ5q776XbFO8HnUggyGse1Z4CFZyVpUdWaIzpFkQdivAACSKmqfE6jAunX7HuujTQhLhVgs/iCQ3ALQfQ118Jh1g2dz7S3/klHJs6JqfXLKtwDHzq2DuEDjls5PPoD6SVipjQo+kFO2tvKUYOrXryGW5VNPSUKtXZJX4kxtLzCANqENMSqZIBiJhXj7+JQq8Kp6E117dkLxh4BmPJmGS4stSAfgSdmEWgm0MgAbHkc2X+fLsWrcEBYaXE1b+n70bVXGDVEfeuMNZjBlsgULVR0DXY5zxegciOSNr1b7yF/ZdoALN0gmQg+AywPy92+oeY7EXLabDoDUKcE+42EHscXEkTHlhCieF/W9worCzGqpMwJuBDNvDu5kP1y/vB+ZfPVTlZ1kS77/OuDTr/zssQI/SgSszVXTyVSFIFIbXLGuUDscnmPHVPV4PnmeOa2aeF1cgX0o/JErQ8+iu2wqQKueZT4QAUFyknIgXloSBVs= mariocs@mario-codescalers"

// job.add_ssh_key('my_key', sshkey)

// vm_config := tfrobot.VMConfig{
// 	name: 'holo_vm'
// 	region: 'europe'
// 	nrcores: 2
// 	memory_gb: 8
// 	ssh_key: 'my_key'
// 	flist: 'https://hub.grid.tf/mariobassem1.3bot/threefolddev-holochain-latest.flist'
// 	pub_ip: true
// 	env_vars: {
// 		'CODE_SERVER_PASSWORD': 'mypass'
// 	}
// }

// job.deploy_vms(vm_config, 1)
// output := job.run()!
// println('output:\n${output}')
// vm := job.vm_get('holo_vm2')?
// vm := tfrobot.VirtualMachine{}
// vm.ssh_interactive()!
// vm.code_server()!

// console.print_debug_title("MYVM", vm.str())
// env:={"tfrobot":"ourmiceliumipaddr"}
