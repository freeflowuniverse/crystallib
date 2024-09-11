
module deploy

import freeflowuniverse.crystallib.data.encoder



// MachineNetworkReq struct to represent network access configuration
@[params]
pub struct VMRequirements {
pub mut:
	name				string
	description	string
	cpu    			int //vcores
	memory 			int //gbyte
	public_ip4  bool
	public_ip6  bool
	planetary   bool
	mycelium    bool
	network 		?NetworkSpecs
	heroscript 	string //will be executed once the node is up & running with hero, this is useful for e.g. redeployment
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
	tfchain_id 					string
	tfchain_contract_id u64
	name            		string
	description 				string
	//TODO: what other enduser info do we need?
}



// // returns bin encoder already populated with all base properties
// fn (self VMachine) encode() ![]u8 {
// 	mut b := encoder.new()
// 	b.add_u8(1)
// 	b.add_string(self.name)
// 	b.add_int(self.cpu)
// 	b.add_int(self.memory)
// 	b.add_bool(self.public_ip4)
// 	// if self.network {
// 	// 	b.add_bool(true)
// 	// 	b....
// 	// }else{
// 	// 	b.add_bool(false)
// 	// }
// 	//TODO
// 	return b
// 	//TODO: description < 32 chars
// }


// fn vm_decode(data []u8) !VMachine {
// 	mut d := encoder.decoder_new(data)
// 	mut self := VMachine{}
// 	version := d.get_u8()
// 	if version != 1{
// 		return error("only support version 1")
// 	}
// 	self.name = d.get_string()
// 	//TODO: decode
// 	networkexists := d.get_bool()
// 	// if networkexists{
// 	// 	self.network ...
// 	// }

// }




// // check if the node where the machine runs on is up and running
// fn (self VMachine) check_node_up() !bool {

// }

// //check on TFChain, RMB, ... if the VM is there and up and running
// fn (self VMachine) check_vm_up() !bool {

// }

// //try to reach the machine over mycelium
// fn (self VMachine) ping_mycelium() !bool {

// }

// fn (self VMachine) healthcheck() ! {
// 	//check we can ping, if not check vm is up, if not check node is up
// 	//wherever we find the issue throw an error

// }


// // NetworkInfo struct to represent network details
// pub struct RecoverArgs {
// pub mut:
// 	reinstall     bool //reinstall if needed and run heroscript
// }

// fn (self VMachine) recover(args RecoverArgs) ! {
// }



// // NetworkInfo struct to represent network details
// pub struct DeployArgs {
// pub mut:
// 	reset     bool //careful will delete existing machine if tjere
// }


// fn (self VMachine) deploy(args DeployArgs) ! {
// 	//check the machine is there, if yes and reset used then delete the machine before deploying a new one

// }

// fn (self VMachine) delete(args DeployArgs) ! {
// 	//delete myself, check on TFChain that deletion was indeed done

// }

