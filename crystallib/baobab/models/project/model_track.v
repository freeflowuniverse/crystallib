module project

import freeflowuniverse.crystallib.baobab.models.system
import freeflowuniverse.crystallib.data.ourtime

// track effort done on issue, story, requirement or task (can be multiple at once)
[root_object]
pub struct Track {
	system.Base
pub mut:
	issues       []system.SmartId [root_object: Issue]
	stories      []system.SmartId [root_object: Story]
	requirements []system.SmartId [root_object: Requirement]
	tasks        []system.SmartId [root_object: Task]
	time         ourtime.OurTime
	description  string
}
