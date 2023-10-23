module tfgrid

import freeflowuniverse.crystallib.data.actionsparser { Action }
import freeflowuniverse.crystallib.threefold.web3gw.tfgrid as tfgrid_client { RemoveVM, VM }
import rand

fn (mut t TFGridHandler) vm(action Action) ! {
	match action.name {
		'create' {
			name := action.params.get_default('name', rand.string(6).to_lower())!
			network := action.params.get_default('network', rand.string(6).to_lower())!
			farm_id := action.params.get_int_default('farm_id', 0)!
			capacity := action.params.get_default('capacity', 'meduim')!
			times := action.params.get_int_default('times', 1)!
			disk_size := action.params.get_storagecapacity_in_gigabytes('disk_size') or { 0 }
			gateway := action.params.get_default_false('gateway')
			wg := action.params.get_default_false('add_wireguard_access')
			public_ipv4 := action.params.get_default_false('add_public_ipv4')
			public_ipv6 := action.params.get_default_false('add_public_ipv6')

			ssh_key_name := action.params.get_default('sshkey', 'default')!
			ssh_key := t.get_ssh_key(ssh_key_name)!

			deploy_res := t.tfgrid.deploy_vm(VM{
				name: name
				network: network
				farm_id: u32(farm_id)
				capacity: capacity
				ssh_key: ssh_key
				times: u32(times)
				disk_size: u32(disk_size)
				gateway: gateway
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

			remove_res := t.tfgrid.remove_vm(RemoveVM{
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
