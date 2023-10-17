module project

import freeflowuniverse.crystallib.baobab.models.system
import freeflowuniverse.crystallib.data.ourtime

pub struct Epic {
	system.Base
pub mut:
	name        string
	description string
	deadline    ourtime.OurTime
}
