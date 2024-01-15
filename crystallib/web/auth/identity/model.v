module identity

pub struct User {
pub:
	id string
pub mut:
	group_id int
	name string
	email string
	phone string
}

pub struct Group {
pub:
	name string
	members []string [fkey: group_id]
}