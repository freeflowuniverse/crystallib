module project

import freeflowuniverse.crystallib.baobab.db

[root_object]
pub struct CostCenter {
	db.Base
pub mut:
	name        string
	title       string
	description string
}
