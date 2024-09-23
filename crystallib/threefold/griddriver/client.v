module griddriver

pub struct Client {
pub:
	mnemonic  string
	substrate string
	relay     string
mut:
	node_twin map[u32]u32
}

// TODO: add the rest of griddriver functionalities
