import freeflowuniverse.crystallib.clients.dagu
import freeflowuniverse.crystallib.osal.dagu as dagu_osal
import os

mut client := dagu.new(
	url: 'http://${os.args[1]}'
	username: 'admin'
	password: 'password'
) or {panic('failed to create dagu')}

if 'holochain_scaffold' in client.list_dags()!.dags.map(it.dag.name) {
	client.delete_dag('holochain_scaffold')!
}

client.new_dag(
	name: 'holochain_scaffold'
	env: {'PATH':'/root/.nix-profile/bin:/root/hero/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:\$PATH'}
	steps: [
		dagu_osal.Step {
			name: 'Verify installation'
			command: 'nix run --refresh -j0 -v github:holochain/holochain#hc-scaffold -- --version'
		},
		dagu_osal.Step {
			name: 'Create working directory'
			command: 'mkdir -p /root/Holochain'
			depends: ['Verify installation']
		},
		dagu_osal.Step {
			name: 'Scaffold application'
			dir: '/root/Holochain'
			description: 'Scaffold a simple “Hello, World!” Holochain application'
			command: 'bash'
			script: 'nix run github:holochain/holochain#hc-scaffold -- example hello-world || true'
			continue_on: dagu_osal.ContinueOn{failure: true}
			depends: ['Create working directory']
		},
		dagu_osal.Step {
			name: 'Run application'
			dir: '/root/Holochain/hello-world'
			command: 'nix develop --command bash -c "npm install && npm run start" && exit'
			depends: ['Scaffold application']
		}
	]
)!

client.start_dag('holochain_scaffold')!
