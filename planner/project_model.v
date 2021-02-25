module planner
import time

pub enum ProjectStatus {
	suggested
	approved
	started
	verify
	closed
}

pub struct Project {
pub mut:
	id 	  	     int
	name         string
	state        ProjectStatus
	stories 	 []int
	issues 	     []int
	tasks        []int
	members 	 []MemberShip
	deadline 	 time.Time
	dependencies []int //dependencies to other projects
	description  string
	comments 	 []int

}

pub enum MemberType {
	owner
	stakeholder
	member
	observer
}

pub struct MemberShip {
pub mut:
	person       int
	group 		 int
	membertype 	 MemberType
	expiration   time.Time
	reputation   int = 50
}


