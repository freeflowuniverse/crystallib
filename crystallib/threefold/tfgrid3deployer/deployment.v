module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.data.encoder
import freeflowuniverse.crystallib.ui.console
import encoding.base64
import os
import compress.zlib
import encoding.hex
import x.crypto.chacha20
import crypto.sha256
import rand

@[heap]
pub struct TFDeployment {
pub mut:
	name        string
	description string
	vms         []VMachine
	zdbs        []ZDBResult
	webnames    []WebNameResult
	network     ?NetworkSpecs
mut:
	contracts []u64 // Set the deployed contracts on the deployment and save the full deployment to be able to delete the whole deployment when need.
	deployer  grid.Deployer @[skip; str: skip]
	kvstore   KVStoreFS     @[skip; str: skip]
}

pub fn new_deployment(name string) !TFDeployment {
	mut grid_client := get()!

	network := match grid_client.network {
		.dev { grid.ChainNetwork.dev }
		.qa { grid.ChainNetwork.qa }
		.test { grid.ChainNetwork.test }
		.main { grid.ChainNetwork.main }
	}

	deployer := grid.new_deployer(grid_client.mnemonic, network)!

	return TFDeployment{
		name: name
		deployer: deployer
		kvstore: KVStoreFS{}
	}
}

pub fn (mut self TFDeployment) deploy() ! {
	console.print_header('Starting deployment process.')
	mut network_specs := self.network or {
		NetworkSpecs{
			name: 'net' + rand.string(5)
			ip_range: '10.10.0.0/16'
		}
	}

	self.network = network_specs

	mut setup := DeploymentSetup{
		deployer: &self.deployer
		network_name: network_specs.name
		ip_range: network_specs.ip_range
		mycelium: network_specs.mycelium
	}

	setup.collect_node_ids(mut self.vms) or { return error('Failed to collect node IDs: ${err}') }

	console.print_header('Loaded nodes: ${setup.nodes}.')

	setup.setup_network_workloads()!
	setup.setup_vm_workloads(self.vms)!
	setup.setup_zdb_workloads(self.zdbs)!
	setup.setup_webname_workloads(mut self.webnames)!
	self.finalize_deployment(setup)!

	// self.contracts = setup.contracts_map.values()

	// for mut vm in self.vms {
	// 	vm.tfchain_contract_id = setup.contracts_map[vm.requirements.nodes[0]]
	// }

	self.save()!
}

fn (mut self TFDeployment) finalize_deployment(setup DeploymentSetup) ! {
	// for name_contract in setup.name_contracts {
	// 	name_contract_id := setup.deployer.client.create_name_contract(name_contract)!
	// 	console.print_header('name contract ${name_contract} created with id ${name_contract_id}')

	// 	setup.name_contract_map[name_contract] = name_contract_id
	// }
	mut dls := map[u32]&grid_models.Deployment{}
	for node_id, workloads in setup.workloads {
		console.print_header('Creating deployment on node ${node_id}.')
		mut deployment := grid_models.new_deployment(
			twin_id: setup.deployer.twin_id
			description: 'VGridClient Deployment'
			workloads: workloads
			signature_requirement: grid_models.SignatureRequirement{
				weight_required: 1
				requests: [
					grid_models.SignatureRequest{
						twin_id: u32(setup.deployer.twin_id)
						weight: 1
					},
				]
			}
		)

		deployment.add_metadata('deployment', self.name)

		dls[node_id] = &deployment
		// contract_id := setup.deployer.deploy(node_id, mut deployment, deployment.metadata,
		// 	0) or { return error('Deployment failed on node ${node_id}: ${err}') }

		// TODO: Fill the structs with the result.

		// setup.contracts_map[node_id] = contract_id
		// console.print_header('Deployment successful. Contract ID: ${contract_id}')
	}
	console.print_header('Batch deploy')
	name_contracts_map, ret_dls := self.deployer.batch_deploy(setup.name_contracts, mut
		dls, none)!

	// self.update_state(deployemnt)
}

pub fn (mut self TFDeployment) vm_get(vm_name string) !VMachine {
	d := self.load()!
	println('d = ${d}')
	// return d.vms
	// Placeholder to change this later to return only vm.
	return VMachine{}
}

pub fn (mut self TFDeployment) load() !TFDeployment {
	value := self.kvstore.get(self.name)!
	decrypted := self.decrypt(value)!
	decompressed := self.decompress(decrypted)!
	decoded := self.decode(decompressed)!
	return decoded
}

fn (mut self TFDeployment) save() ! {
	encoded_data := self.encode()!
	self.kvstore.set(self.name, encoded_data)!
}

fn (self TFDeployment) compress(data []u8) ![]u8 {
	return zlib.compress(data) or { error('Cannot compress the data due to: ${err}') }
}

fn (self TFDeployment) decompress(data []u8) ![]u8 {
	return zlib.decompress(data) or { error('Cannot decompress the data due to: ${err}') }
}

fn (self TFDeployment) encrypt(compressed []u8) ![]u8 {
	key_hashed := sha256.hexhash(self.deployer.mnemonics)
	name_hashed := sha256.hexhash(self.name)
	key := hex.decode(key_hashed)!
	nonce := hex.decode(name_hashed)![..12]
	encrypted := chacha20.encrypt(key, nonce, compressed) or {
		return error('Cannot encrypt the data due to: ${err}')
	}
	return encrypted
}

fn (self TFDeployment) decrypt(data []u8) ![]u8 {
	key_hashed := sha256.hexhash(self.deployer.mnemonics)
	name_hashed := sha256.hexhash(self.name)
	key := hex.decode(key_hashed)!
	nonce := hex.decode(name_hashed)![..12]

	compressed := chacha20.decrypt(key, nonce, data) or {
		return error('Cannot decrypt the data due to: ${err}')
	}
	return compressed
}

fn (self TFDeployment) encode() ![]u8 {
	mut b := encoder.new()
	b.add_string(self.name)
	b.add_int(self.vms.len)

	for vm in self.vms {
		vm_data := vm.encode()!
		b.add_int(vm_data.len)
		b.add_bytes(vm_data)
		// zd.encode()
		// k8s.encode() ...etc
	}

	compressed := self.compress(b.data)!
	encrypted := self.encrypt(compressed)!
	return encrypted
}

fn (self TFDeployment) decode(data []u8) !TFDeployment {
	if data.len == 0 {
		return error('Data cannot be empty')
	}

	mut d := encoder.decoder_new(data)
	mut result := TFDeployment{
		name: d.get_string()
	}

	num_vms := d.get_int()

	for _ in 0 .. num_vms {
		d.get_int()
		vm_data := d.get_bytes()
		// mut dd := encoder.decoder_new(vm_data)
		vm := decode_vmachine(vm_data)!
		result.vms << vm
	}

	// ZDB & NAMES

	return result
}

// Set a new machine on the deployment.
pub fn (mut self TFDeployment) add_machine(requirements VMRequirements) {
	self.vms << VMachine{
		requirements: requirements
	}
}

// Set a new zdb on the deployment.
pub fn (mut self TFDeployment) add_zdb(zdb ZDBRequirements) {
	self.zdbs << ZDBResult{
		requirements: zdb
	}
}

// Set a new webname on the deployment.
pub fn (mut self TFDeployment) add_webname(requirements WebNameRequirements) {
	self.webnames << WebNameResult{
		requirements: requirements
	}
}
