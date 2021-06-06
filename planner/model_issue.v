module planner

import time

pub enum IssueStatus {
	suggested
	approved
	started
	verify
	closed
}

pub enum IssueType {
	pr
	feature
	bug
	question
	deal
	lead
}

pub struct Issue {
pub mut:
	id           int
	title        string
	state        IssueStatus
	members      []IssueMemberShip
	deadline     time.Time
	dependencies []int // dependencies to other projects
	description  string
	comments     []int
}

pub enum IssueMemberType {
	owner
	stakeholder
	member
	observer
}

pub struct IssueMemberShip {
pub mut:
	person     string
	group      string
	membertype IssueMemberType
	expiration time.Time
}
