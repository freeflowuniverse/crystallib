module play

import freeflowuniverse.crystallib.data.fskvs

//make sure the initial secrets are set and all is ready for utilization
pub fn init_default() ! {
	fskvs.dbcontext_init_default()!
}

