module components

pub struct Form {
pub:
	id string
	content IComponent
}

pub fn (form Form) html() string {
	return '<form id="${form.id}">${form.content.html()}</form>'
}