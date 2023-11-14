module project

import freeflowuniverse.crystallib.baobab.db
import freeflowuniverse.crystallib.baobab.smartid

[root_object]
pub struct Team {
	db.Base
pub mut:
	name        string
	title       string
	description string
	members     []smartid.GID [root_object: Person] // id's users who are part of team
}

// import time

// pub enum TeamStatus {
// 	suggested
// 	approved
// 	active
// 	closed
// }

// pub struct Team {
// pub mut:
// 	id          int
// 	name        string
// 	state       TeamStatus
// 	members     []TeamMemberShip
// 	description string
// 	comments    []int
// }

// pub enum TeamMemberType {
// 	owner
// 	stakeholder
// 	member
// 	observer
// }

// pub struct TeamMemberShip {
// pub mut:
// 	id         int
// 	person     string
// 	group      string
// 	membertype TeamMemberType
// 	// expiration system.OurTime
// 	// reputation int = 5
// }
