module project

import freeflowuniverse.crystallib.baobab.models.system

pub struct Requirement {
	system.Base
pub mut:
	story       system.SmartId   [required; root_object: Story]
	title       string
	description string
	assignment  []system.SmartId [root_object: 'Person, Team']
	priority    Priority
	state       RequirementState
}

pub enum RequirementState {
	unknown
	metonce
	metmulti
}
