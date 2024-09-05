module models
import freeflowuniverse.crystallib.threefold.grid

pub struct MachineNetworkAccessModel {
	pub mut:
		public_ip bool
		public_ip6 bool
		planetary bool
		mycelium bool
}

pub struct NetworkModel {
	pub mut:
		name string
		ip_range string
}

pub struct MachineModel {
	pub mut:
		name string
		deployment_name  string
		network_access MachineNetworkAccessModel
		capacity ComputeCapacity
		pub_sshkeys []string
		nodeid int
}

pub struct GridVM {
	mnemonic string
	chain_network grid.ChainNetwork

	pub mut:
		network NetworkModel
		machines []MachineModel
		name string
		metadata string
}

pub fn (mut mm GridVM)deploy(vms GridVM) ! {
	mut deployer := grid.new_deployer(mm.mnemonic, mm.chain_network)!
	// println(grid.)
	// println(vms)
}

pub fn (mut mm GridVM)delete(){
	println("Not Implemented")
}
pub fn (mut mm GridVM)get(){
	println("Not Implemented")
}
pub fn (mut mm GridVM)update(){
	println("Not Implemented")
}