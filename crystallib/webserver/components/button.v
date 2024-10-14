module components

pub struct Button{
pub:
	content string
}

pub fn (button Button) html() string {
	return '<button>${button.content}</button>'
}