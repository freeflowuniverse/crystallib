module grid

import os
import json
import time
import log
import freeflowuniverse.crystallib.threefold.grid.models
import freeflowuniverse.crystallib.threefold.griddriver

pub struct Deployer {
pub:
	mnemonics     string
	substrate_url string
	twin_id       u32
	relay_url     string
	env           string
pub mut:
	client griddriver.Client
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
	mut client := griddriver.Client{
		mnemonic: mnemonics
		substrate: grid.substrate_url[chain_network]
		relay: grid.relay_url[chain_network]
	}
	twin_id := client.get_user_twin()!

	return Deployer{
		mnemonics: mnemonics
		substrate_url: grid.substrate_url[chain_network]
		twin_id: twin_id
		relay_url: grid.relay_url[chain_network]
		env: grid.envs[chain_network]
		logger: logger
		client: client
	}
}

fn (mut d Deployer) handle_deploy(node_id u32, mut dl models.Deployment, hash_hex string) !u64 {
	signature := d.client.sign_deployment(hash_hex)!
	dl.add_signature(d.twin_id, signature)
	payload := dl.json_encode()

	node_twin_id := d.client.get_node_twin(node_id)!
	d.rmb_deployment_deploy(node_twin_id, payload)!

	mut versions := map[string]u32{}
	for wl in dl.workloads {
		versions[wl.name] = 0
	}
	d.wait_deployment(node_id, dl.contract_id, versions)!
	return dl.contract_id
}

pub fn (mut d Deployer) update_deployment(node_id u32, mut dl models.Deployment, body string) ! {
	// get deployment
	// assign new workload versions
	// update contract
	// update deployment
	old_dl := d.get_deployment(dl.contract_id, node_id)!
	if !is_deployment_up_to_date(old_dl, dl) {
		return error('deployment is up to date')
	}

	new_versions := d.update_versions(old_dl, mut dl)

	hash_hex := dl.challenge_hash().hex()
	signature := d.client.sign_deployment(hash_hex)!
	dl.add_signature(d.twin_id, signature)
	payload := dl.json_encode()

	d.client.update_node_contract(dl.contract_id, body, hash_hex)!

	node_twin_id := d.client.get_node_twin(node_id)!
	d.rmb_deployment_update(node_twin_id, payload)!
	d.wait_deployment(node_id, dl.contract_id, new_versions)!
}

// update_versions increments the deployment version
// and updates the updated workloads versions
fn (mut d Deployer) update_versions(old_dl models.Deployment, mut new_dl models.Deployment) map[string]u32 {
	mut old_hashes := map[string]string{}
	mut old_versions := map[string]u32{}
	mut new_versions := map[string]u32{}

	for wl in old_dl.workloads {
		hash := wl.challenge_hash().hex()
		old_hashes[wl.name] = hash
		old_versions[wl.name] = wl.version
	}

	new_dl.version = old_dl.version + 1

	for mut wl in new_dl.workloads {
		hash := wl.challenge_hash().hex()

		if old_hashes[wl.name] != hash {
			wl.version = new_dl.version
		} else {
			wl.version = old_versions[wl.name]
		}

		new_versions[wl.name] = wl.version
	}

	return new_versions
}

// same_workloads checks if both deployments have the same workloads, even if updated
// this has to be done since a workload name is not included in a deployment's hash
// so a user could just replace a workloads's name, and still get the same deployment's hash
// but with a totally different workload, since a workload is identified by it's name
fn same_workloads(dl1 models.Deployment, dl2 models.Deployment) bool {
	if dl1.workloads.len != dl2.workloads.len {
		return false
	}

	mut names := map[string]bool{}
	for wl in dl1.workloads {
		names[wl.name] = true
	}

	for wl in dl2.workloads {
		if !names[wl.name] {
			return false
		}
	}

	return true
}

// is_deployment_up_to_date checks if new_dl is different from old_dl
fn is_deployment_up_to_date(old_dl models.Deployment, new_dl models.Deployment) bool {
	old_hash := old_dl.challenge_hash().hex()
	new_hash := new_dl.challenge_hash().hex()
	if old_hash != new_hash {
		return true
	}

	return !same_workloads(old_dl, new_dl)
}

pub fn (mut d Deployer) deploy(node_id u32, mut dl models.Deployment, body string, solution_provider u64) !u64 {
	public_ips := dl.count_public_ips()
	hash_hex := dl.challenge_hash().hex()

	contract_id := d.client.create_node_contract(node_id, body, hash_hex, public_ips,
		solution_provider)!
	d.logger.info('ContractID: ${contract_id}')
	dl.contract_id = contract_id

	return d.handle_deploy(node_id, mut dl, hash_hex) or {
		d.logger.info('Rolling back...')
		d.logger.info('deleting contract id: ${contract_id}')
		d.client.cancel_contract(contract_id)!
		return err
	}
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
	twin_id := d.client.get_node_twin(node_id)!
	payload := {
		'contract_id': contract_id
	}
	res := d.rmb_deployment_get(twin_id, json.encode(payload))!
	return json.decode(models.Deployment, res)
}

pub fn (mut d Deployer) deployment_changes(node_id u32, contract_id u64) ![]models.Workload {
	twin_id := d.client.get_node_twin(node_id)!

	res := d.rmb_deployment_changes(twin_id, contract_id)!
	return json.decode([]models.Workload, res)
}
