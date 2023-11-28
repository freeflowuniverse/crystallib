module model

// Data object for user
@[inherit: 'base']
@[root]
pub struct User {
pub mut:
	contacts []Contact @[model: 'usermgmt.usermanager.contact'] // list of contacts for a user
}

pub struct Contact {
pub mut:
	name string
}
