module grid

import freeflowuniverse.crystallib.clients.redisclient

struct DeploymentStateDB{
	redis redisclient.Redis
	secret string //to encrypt symmetric
}

struct DeploymentState{
	name string
	vms []VMDeployed
	zdbs []ZDBDeployed
}

pub fn (db DeploymentStateDB) set(deployment_name string, key string, val string)! {
	//store  e.g. \n separated list of all keys per deployment_name
	//encrypt
}

// pub fn (db DeploymentStateDB) get(deployment_name string, key string)!string {

// }

// pub fn (db DeploymentStateDB) delete(deployment_name string, key string)! {

// }

// pub fn (db DeploymentStateDB) keys(deployment_name string)![]string {

// }

// pub fn (db DeploymentStateDB) load(deployment_name string)!DeploymentState {

// }