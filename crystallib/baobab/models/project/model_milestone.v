module project

import freeflowuniverse.crystallib.baobab.models.system
import freeflowuniverse.crystallib.data.ourtime

[root_object]
pub struct Milestone {
	system.Base
pub mut:
	name         string
	title        string
	description  string
	priority     Priority
	deadline     ourtime.OurTime
	percent_done f64
	state        State
	project_id   system.SmartId       [root_object: Project]
	owners       []system.SmartId     [root_object: Person]
	epics        []system.SmartId     [root_object: Epic]
}
