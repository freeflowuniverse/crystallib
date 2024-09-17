
module tfgrid3deployer

import json
import freeflowuniverse.crystallib.data.encoder

// MachineNetworkReq struct to represent network access configuration
@[params]
pub struct VMRequirements {
pub mut:
	name        string
	description string
	cpu         int // vcores
	memory      int // gbyte
	public_ip4  bool
	public_ip6  bool
	planetary   bool
	mycelium    bool
	network     ?NetworkSpecs
	nodes       []int  // if set will chose a node from the list to deploy on
}

// NetworkInfo struct to represent network details
pub struct NetworkSpecs {
pub mut:
	name     string
	ip_range string
	subnet   string
}

// MachineModel struct to represent a machine and its associated details
pub struct VMachine {
pub mut:
	tfchain_id          string
	tfchain_contract_id int //TODO: make multiple entries
	requirements VMRequirements
}

// Helper function to encode a VMachine
fn (self VMachine) encode() ![]u8 {
	// mut b := encoder.new()
	// b.add_string(self.name)
	// b.add_string(self.tfchain_id)
	// b.add_int(self.tfchain_contract_id)
	// b.add_int(self.cpu)
	// b.add_int(self.memory)
	// b.add_string(self.description)
	// for now we just use json, will do bytes when needed
	return json.encode(self).bytes()
}

// Helper function to decode a VMachine
fn decode_vmachine(data []u8) !VMachine {
	// mut d encoder.Decode
	// return VMachine{
	// 	name:                d.get_string()
	// 	tfchain_id:          d.get_string()
	// 	tfchain_contract_id: d.get_int()
	// 	cpu:                 d.get_int()
	// 	memory:              d.get_int()
	// 	description:         d.get_string()
	// }
	data_string := data.bytestr()
    return json.decode(VMachine, data_string)
}

// check if the node where the machine runs on is up and running
fn (self VMachine) check_node_up() !bool {
	return true

}

//check on TFChain, RMB, ... if the VM is there and up and running
fn (self VMachine) check_vm_up() !bool {
return true
}

//try to reach the machine over mycelium
fn (self VMachine) ping_mycelium() !bool {
return true
}

fn (self VMachine) healthcheck() ! {
	//check we can ping, if not check vm is up, if not check node is up
	//wherever we find the issue throw an error
}

// NetworkInfo struct to represent network details
pub struct RecoverArgs {
pub mut:
	reinstall     bool //reinstall if needed and run heroscript
}

fn (self VMachine) recover(args RecoverArgs) ! {
}

// NetworkInfo struct to represent network details
pub struct DeployArgs {
pub mut:
	reset     bool //careful will delete existing machine if tjere
}

fn (self VMachine) deploy(args DeployArgs) ! {
	//check the machine is there, if yes and reset used then delete the machine before deploying a new one

}

fn (self VMachine) delete(args DeployArgs) ! {
	//delete myself, check on TFChain that deletion was indeed done

}
