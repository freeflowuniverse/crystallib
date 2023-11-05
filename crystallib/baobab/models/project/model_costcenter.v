module project

import freeflowuniverse.crystallib.baobab.models.system

[root_object]
pub struct CostCenter {
	system.Base
pub mut:
	name        string
	title       string
	description string
}
