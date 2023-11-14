module project

import freeflowuniverse.crystallib.baobab.db
import freeflowuniverse.crystallib.data.ourtime

pub struct Epic {
	db.Base
pub mut:
	name        string
	description string
	deadline    ourtime.OurTime
}
