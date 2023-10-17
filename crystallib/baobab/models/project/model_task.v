module project

import freeflowuniverse.crystallib.baobab.models.system
import freeflowuniverse.crystallib.data.ourtime

[root_object]
pub struct Task {
	system.Base
pub mut:
	story            system.SmartId   [root_object: Story]
	title            string
	description      string
	priority         Priority
	assignment       []system.SmartId [root_object: 'Person, Team']
	deadline         ourtime.OurTime
	effort_remaining int // hours remaining
	percent_done     f64
	state            State
	costcenters      []system.SmartId [root_object: CostCenter]
}
