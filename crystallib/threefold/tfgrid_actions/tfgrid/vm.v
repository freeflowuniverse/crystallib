module tfgrid

import freeflowuniverse.crystallib.data.actionsparser { Action }
import freeflowuniverse.crystallib.threefold.web3gw.tfgrid as tfgrid_client { RemoveVM, VM }
import rand

fn (mut t TFGridHandler) vm(action Action) ! {
	match action.name {
		'create' {
			wg := action.params.get_default_false('add_wireguard_access')
			gateway := action.params.get_default_false('gateway')

			name := action.params.get_default('name', rand.string(6).to_lower())!
			node_id := action.params.get_int_default('node_id', 0)!
			farm_id := action.params.get_int_default('farm_id', 0)!
			flist := action.params.get_default('flist', 'https://hub.grid.tf/tf-official-apps/base:latest.flist')
			entrypoint := action.params.get_default('entrypoint', '/sbin/zinit init')
			public_ipv4 := action.params.get_default_false('add_public_ipv4')
			public_ipv6 := action.params.get_default_false('add_public_ipv6')
			planetary := action.params.get_default_false('planetary')
			cpu := action.params.get_int_default('cpu', 1)!
			memory := action.params.get_int_default('memory', 1024)!
			rootfs := action.params.get_int_default('rootfs', 2048)!
			disk_size := action.params.get_int_default('disk', 0)!
			zlog := action.params.get_default('zlog', '')
			ssh_key_name := action.params.get_default('sshkey', 'default')!
			ssh_key := t.get_ssh_key(ssh_key_name)!

			deploy_res := t.tfgrid.deploy_vm(DeployVM{
				name: name
				network: network
				farm_id: u32(farm_id)
				add_wireguard_access: wg
				add_public_ipv4: public_ipv4
				add_public_ipv6: public_ipv6
			})!

			t.logger.info('${deploy_res}')
		}
		'get' {
			network := action.params.get('network')!

			get_res := t.tfgrid.get_vm(network)!

			t.logger.info('${get_res}')
		}
		'remove' {
			network := action.params.get('network')!
			machine := action.params.get('machine')!

			remove_res := t.tfgrid.remove_vm(RemoveVMFromNetworkDeployment{
				network: network
				vm_name: machine
			})!
			t.logger.info('${remove_res}')
		}
		'delete' {
			network := action.params.get('network')!

			t.tfgrid.delete_vm(network) or { return error('failed to delete vm network: ${err}') }
		}
		else {
			return error('operation ${action.name} is not supported on vms')
		}
	}
}
