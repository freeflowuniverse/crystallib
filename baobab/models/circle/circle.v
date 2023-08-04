module circle

import freeflowuniverse.protocolme.models.people

// group of people (persons)
pub struct Circle {
pub mut:
	name        string
	description string
	members     []&CircleMember
}

pub enum PersonState {
	active
	inactive
	uncertain
}

pub enum Role {
	follower
	stakeholder
	member
	contributor
}

pub struct CircleMember {
pub mut:
	person      string
	description string
	role        Role
	// contribution_fee ContributionFee
	is_admin bool // can manage all properties of the Circle

	active PersonState
}

// add a contact which will be owned by the local twin
pub fn (cm CircleMember) person_get() &people.Person {
	// todo: get person
	p := people.Person{}
	return &p
}
