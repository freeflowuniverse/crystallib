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
	id           int
	name         string
	state        ProjectStatus
	stories      []int
	issues       []int
	tasks        []int
	members      []ProjectMemberShip
	deadline     time.Time
	dependencies []int // dependencies to other projects
	description  string
	comments     []int
}

pub enum ProjectMemberType {
	owner
	stakeholder
	member
	observer
}

pub struct ProjectMemberShip {
pub mut:
	person     string
	group      string
	membertype ProjectMemberType
	expiration time.Time
	reputation int = 50
}
