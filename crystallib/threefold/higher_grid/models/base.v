module models

import freeflowuniverse.crystallib.threefold.grid
import log

pub struct ComputeCapacity {
	pub mut:
	cpu int
	memory int
}

pub struct GridConfig {
	pub mut:
		mnemonic      string
		chain_network grid.ChainNetwork
		node_id       int
}

__global logger = init_logger()

fn init_logger() &log.Log {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	return logger
}
