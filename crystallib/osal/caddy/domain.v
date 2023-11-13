module caddy

// import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib


[heap]
pub struct Domain {
pub mut:
	domain      string //e.g. www.ourworld.tf
	port        int	   //if not filled in then 443
	description string
}

