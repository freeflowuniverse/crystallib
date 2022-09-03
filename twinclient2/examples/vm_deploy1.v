import freeflowuniverse.crystallib.twinclient2 as tw2

mut tw2_client := tw2.init_client(mut ws_client)

go fn [mut tw2_client] () {
	payload := Machines{
		name: 'ms1'
		network: Network{
			ip_range: '10.200.0.0/16'
			name: 'net'
			add_access: false
		}
		machines: [
			Machine{
				name: 'm1'
				node_id: 2
				public_ip: false
				planetary: true
				cpu: 1
				memory: 1024
				rootfs_size: 1
				flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
				entrypoint: '/sbin/zinit init'
				env: Env{
					ssh_key: 'ADD_YOUR_SSH'
				}
			},
		]
	}
	response := client.deploy_machines(machines)?
}()
