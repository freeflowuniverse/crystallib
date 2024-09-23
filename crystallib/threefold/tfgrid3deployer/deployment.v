module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.ui.console
import compress.zlib
import encoding.hex
import x.crypto.chacha20
import crypto.sha256
import rand
import json

struct GridContracts {
pub mut:
	name []u64
	node []u64
	rent []u64
}

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
	// Set the deployed contracts on the deployment and save the full deployment to be able to delete the whole deployment when need.
	contracts GridContracts
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

	kvstore := KVStoreFS{}
	if _ := kvstore.get(name) {
		return error('Deployment with the same name is already exist.')
	}

	deployer := grid.new_deployer(grid_client.mnemonic, network)!

	return TFDeployment{
		name:     name
		deployer: deployer
		kvstore:  kvstore
	}
}

pub fn get_deployment(name string) !TFDeployment {
	mut grid_client := get()!

	network := match grid_client.network {
		.dev { grid.ChainNetwork.dev }
		.qa { grid.ChainNetwork.qa }
		.test { grid.ChainNetwork.test }
		.main { grid.ChainNetwork.main }
	}

	deployer := grid.new_deployer(grid_client.mnemonic, network)!

	mut dl := TFDeployment{
		name:     name
		deployer: deployer
		kvstore:  KVStoreFS{}
	}

	dl.load()!

	return dl
}

pub fn (mut self TFDeployment) deploy() ! {
	console.print_header('Starting deployment process.')
	self.set_nodes()!

	mut network_specs := self.network or {
		NetworkSpecs{
			name:     'net' + rand.string(5)
			ip_range: '10.10.0.0/16'
		}
	}

	self.network = network_specs

	mut setup := DeploymentSetup{
		deployer:     &self.deployer
		network_name: network_specs.name
		ip_range:     network_specs.ip_range
		mycelium:     network_specs.mycelium
	}

	setup.setup_network_workloads(self.vms)!
	setup.setup_vm_workloads(self.vms)!
	setup.setup_zdb_workloads(self.zdbs)!
	setup.setup_webname_workloads(mut self.webnames)!

	self.finalize_deployment(setup)!
	self.save()!
}

fn (mut self TFDeployment) set_nodes() ! {
	for mut vm in self.vms {
		mut node_ids := []u64{}

		for node_id in vm.requirements.nodes {
			node_ids << u64(node_id)
		}

		nodes := filter_nodes(
			node_ids:  node_ids
			healthy:   true
			free_mru:  u64(vm.requirements.memory) * 1024 * 1024 * 1024
			total_cru: u64(vm.requirements.cpu)
			free_ips:  if vm.requirements.public_ip4 { u64(1) } else { none }
			has_ipv6:  if vm.requirements.public_ip6 { vm.requirements.public_ip6 } else { none }
			status:    'up'
		)!

		if nodes.len == 0 {
			if node_ids.len != 0 {
				return error("The provided vm nodes ${node_ids} don't have enough resources.")
			}
			return error('Requested the Grid Proxy and no nodes found.')
		}

		vm.node_id = u32(nodes[0].node_id)
	}

	for mut zdb in self.zdbs {
		size := u64(zdb.requirements.size) * 1024 * 1024 * 1024
		nodes := filter_nodes(free_sru: size, status: 'up', healthy: true)!

		if nodes.len == 0 {
			return error('Requested the Grid Proxy and no nodes found.')
		}

		zdb.node_id = u32(nodes[0].node_id)
	}

	for mut webname in self.webnames {
		nodes := filter_nodes(domain: true, status: 'up', healthy: true)!

		if nodes.len == 0 {
			return error('Requested the Grid Proxy and no nodes found.')
		}

		webname.node_id = u32(nodes[0].node_id)
	}
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
			twin_id:               setup.deployer.twin_id
			description:           'VGridClient Deployment'
			workloads:             workloads
			signature_requirement: grid_models.SignatureRequirement{
				weight_required: 1
				requests:        [
					grid_models.SignatureRequest{
						twin_id: u32(setup.deployer.twin_id)
						weight:  1
					},
				]
			}
		)

		deployment.add_metadata('VGridClient/Deployment', self.name)

		dls[node_id] = &deployment
		// contract_id := setup.deployer.deploy(node_id, mut deployment, deployment.metadata,
		// 	0) or { return error('Deployment failed on node ${node_id}: ${err}') }

		// TODO: Fill the structs with the result.

		// setup.contracts_map[node_id] = contract_id
		// console.print_header('Deployment successful. Contract ID: ${contract_id}')
	}
	console.print_header('Batch deploying the deployment')
	name_contracts_map, ret_dls := self.deployer.batch_deploy(setup.name_contracts, mut
		dls, none)!

	self.update_state(name_contracts_map, ret_dls)!
}

fn (mut self TFDeployment) update_state(name_contracts_map map[string]u64, dls map[u32]&grid_models.Deployment) ! {
	mut workloads := map[u32]map[string]&grid_models.Workload{}

	for node_id, deployment in dls {
		workloads[node_id] = map[string]&grid_models.Workload{}
		for id, _ in deployment.workloads {
			workloads[node_id][deployment.workloads[id].name] = &deployment.workloads[id]
		}
	}

	for _, contract_id in name_contracts_map {
		self.contracts.name << contract_id
	}

	for _, dl in dls {
		self.contracts.node << dl.contract_id
	}

	for mut vm in self.vms {
		vm_workload := workloads[vm.node_id][vm.requirements.name]
		res := json.decode(grid_models.ZmachineResult, vm_workload.result.data)!
		vm.mycelium_ip = res.mycelium_ip
		vm.planetary_ip = res.planetary_ip
		vm.wireguard_ip = res.ip
		vm.tfchain_contract_id = dls[vm.node_id].contract_id

		if vm.requirements.public_ip4 || vm.requirements.public_ip6 {
			ip_workload := workloads[vm.node_id]['${vm.requirements.name}_pubip']
			ip_res := json.decode(grid_models.PublicIPResult, ip_workload.result.data)!
			vm.public_ip4 = ip_res.ip
			vm.public_ip6 = ip_res.ip6
		}
	}

	for mut zdb in self.zdbs {
		zdb_workload := workloads[zdb.node_id][zdb.requirements.name]
		res := json.decode(grid_models.ZdbResult, zdb_workload.result.data)!
		zdb.ips = res.ips
		zdb.namespace = res.namespace
		zdb.port = res.port
		zdb.contract_id = dls[zdb.node_id].contract_id
	}

	for mut wn in self.webnames {
		wn_workload := workloads[wn.node_id][wn.requirements.name]
		res := json.decode(grid_models.GatewayProxyResult, wn_workload.result.data)!
		wn.fqdn = res.fqdn
		wn.node_contract_id = dls[wn.node_id].contract_id
		wn.name_contract_id = name_contracts_map[wn.requirements.name]
	}
}

pub fn (mut self TFDeployment) vm_get(vm_name string) !VMachine {
	for vmachine in self.vms {
		if vmachine.requirements.name == vm_name {
			return vmachine
		}
	}
	return error('Machine does not exist.')
}

pub fn (mut self TFDeployment) zdb_get(zdb_name string) !ZDBResult {
	for zdb in self.zdbs {
		if zdb.requirements.name == zdb_name {
			return zdb
		}
	}
	return error('Zdb does not exist.')
}

pub fn (mut self TFDeployment) webname_get(wn_name string) !WebNameResult {
	for wbn in self.webnames {
		if wbn.requirements.name == wn_name {
			return wbn
		}
	}
	return error('Webname does not exist.')
}

pub fn (mut self TFDeployment) load() ! {
	value := self.kvstore.get(self.name)!
	decrypted := self.decrypt(value)!
	decompressed := self.decompress(decrypted)!
	self.decode(decompressed)!
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
	// TODO: Change to 'encoder'

	data := json.encode(self).bytes()

	compressed := self.compress(data)!
	encrypted := self.encrypt(compressed)!
	return encrypted
}

fn (mut self TFDeployment) decode(data []u8) ! {
	obj := json.decode(TFDeployment, data.bytestr())!
	self.vms = obj.vms
	self.zdbs = obj.zdbs
	self.webnames = obj.webnames
	self.contracts = obj.contracts
	self.network = obj.network
	self.name = obj.name
	self.description = obj.description
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
