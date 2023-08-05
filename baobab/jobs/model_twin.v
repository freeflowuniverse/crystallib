module jobs

import freeflowuniverse.crystallib.params { Params }
import time

// The possible states of a job
pub enum TwinState {
	active
	unreacheable
}

pub enum TwinConnection {
	redis
	ipv6
	ipv4
	nats
}


//how can a twin be found
pub struct TwinPointer {
pub mut:
	address      string // ipaddress or redis connection string
	twinid       u32    // which twin needs to execute the action
	pubaddr		string  
}
