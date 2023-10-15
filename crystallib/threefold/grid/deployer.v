module tfgrid

import os
import json
import time
import log
import freeflowuniverse.crystallib.threefold.grid.models

pub struct Deployer {
pub:
	mnemonics     string
	substrate_url string
	twin_id       u32
	relay_url     string
	env           string
pub mut:
	logger log.Log
}

pub enum ChainNetwork {
	dev
	qa
	test
	main
}

const substrate_url = {
	ChainNetwork.dev:  'wss://tfchain.dev.grid.tf/ws'
	ChainNetwork.qa:   'wss://tfchain.qa.grid.tf/ws'
	ChainNetwork.test: 'wss://tfchain.test.grid.tf/ws'
	ChainNetwork.main: 'wss://tfchain.grid.tf/ws'
}

const envs = {
	ChainNetwork.dev:  'dev'
	ChainNetwork.qa:   'qa'
	ChainNetwork.test: 'test'
	ChainNetwork.main: 'main'
}

const relay_url = {
	ChainNetwork.dev:  'wss://relay.dev.grid.tf'
	ChainNetwork.qa:   'wss://relay.qa.grid.tf'
	ChainNetwork.test: 'wss://relay.test.grid.tf'
	ChainNetwork.main: 'wss://relay.grid.tf'
}

pub fn get_mnemonics() !string {
	mnemonics := os.getenv('MNEMONICS')
	if mnemonics == '' {
		return error('failed to get mnemonics, run `export MNEMONICS=....`')
	}
	return mnemonics
}

pub fn new_deployer(mnemonics string, chain_network ChainNetwork, mut logger log.Log) !Deployer {
	twin_id := get_user_twin(mnemonics, tfgrid.substrate_url[chain_network])!

	return Deployer{
		mnemonics: mnemonics
		substrate_url: tfgrid.substrate_url[chain_network]
		twin_id: twin_id
		relay_url: tfgrid.relay_url[chain_network]
		env: tfgrid.envs[chain_network]
		logger: logger
	}
}

fn (mut d Deployer) handel_deploy(node_id u32, mut dl models.Deployment, body string, solution_provider u64, hash_hex string) !u64 {
	signature := d.sign_deployment(hash_hex)!
	dl.add_signature(d.twin_id, signature)
	payload := dl.json_encode()

	node_twin_id := get_node_twin(node_id, d.substrate_url)!
	d.rmb_deployment_deploy(node_twin_id, payload)!
	workload_versions := d.assign_versions(dl)
	d.wait_deployment(node_id, dl.contract_id, workload_versions)!
	return dl.contract_id
}

pub fn (mut d Deployer) deploy(node_id u32, mut dl models.Deployment, body string, solution_provider u64) !u64 {
	public_ips := dl.count_public_ips()
	hash_hex := dl.challenge_hash().hex()

	contract_id := d.create_node_contract(node_id, body, hash_hex, public_ips, solution_provider)!
	d.logger.info('ContractID: ${contract_id}')
	dl.contract_id = contract_id

	return d.handel_deploy(node_id, mut dl, body, solution_provider, hash_hex) or {
		d.logger.info('Rolling back...')
		d.logger.info('deleting contract id: ${contract_id}')
		d.cancel_contract(contract_id)!
		return err
	}
}

pub fn (mut d Deployer) assign_versions(dl models.Deployment) map[string]u32 {
	mut workload_versions := map[string]u32{}
	for wl in dl.workloads {
		workload_versions[wl.name] = wl.version
	}
	return workload_versions
}

pub fn (mut d Deployer) wait_deployment(node_id u32, contract_id u64, workload_versions map[string]u32) ! {
	start := time.now()
	num_workloads := workload_versions.len
	for {
		mut state_ok := 0
		changes := d.deployment_changes(node_id, contract_id)!
		for wl in changes {
			if wl.version == workload_versions[wl.name]
				&& wl.result.state == models.result_states.ok {
				state_ok++
			} else if wl.version == workload_versions[wl.name]
				&& wl.result.state == models.result_states.error {
				return error('failed to deploy deployment due error: ${wl.result.message}')
			}
		}
		if state_ok == num_workloads {
			return
		}
		if (time.now() - start).minutes() > 5 {
			return error('failed to deploy deployment: contractID: ${contract_id}, some workloads are not ready after wating 5 minutes')
		} else {
			d.logger.info('Waiting for deployment to become ready')
			time.sleep(1 * time.second)
		}
	}
}

pub fn (mut d Deployer) get_deployment(contract_id u64, node_id u32) !models.Deployment {
	twin_id := get_node_twin(node_id, d.substrate_url)!
	payload := {
		'contract_id': contract_id
	}
	res := d.rmb_deployment_get(twin_id, json.encode(payload))!
	return json.decode(models.Deployment, res)
}

pub fn (mut d Deployer) deployment_changes(node_id u32, contract_id u64) ![]models.Workload {
	twin_id := get_node_twin(node_id, d.substrate_url)!

	res := d.rmb_deployment_changes(twin_id, contract_id)!
	return json.decode([]models.Workload, res)
}

pub fn (mut d Deployer) sign_deployment(hash string) !string {
	res := os.execute("grid-cli sign  --substrate \"${d.substrate_url}\" --mnemonics \"${d.mnemonics}\"  --hash \"${hash}\"")
	if res.exit_code != 0 {
		return error(res.output)
	}
	return res.output
}

pub fn (mut d Deployer) deploy_single_vm(node_id u32, solution_type string, vm models.VM) !string {
	data := vm.json_encode()
	res := os.execute("grid-cli deploy-single --mnemonics \"${d.mnemonics}\" --env ${d.env} --solution_type \"${solution_type}\" --node ${node_id} --data '${data}'")
	return res.output
}
