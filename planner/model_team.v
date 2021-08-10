module planner

// import time

pub enum TeamStatus {
	suggested
	approved
	active
	closed
}

pub struct Team {
pub mut:
	id          int
	name        string
	state       TeamStatus
	members     []TeamMemberShip
	description string
	comments    []int
}

pub enum TeamMemberType {
	owner
	stakeholder
	member
	observer
}

pub struct TeamMemberShip {
pub mut:
	id         int
	person     string
	group      string
	membertype TeamMemberType
	// expiration time.Time
	// reputation int = 5
}
