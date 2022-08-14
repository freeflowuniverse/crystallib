module markdown

pub struct Doc{
pub mut:
	items []DocItem
}


type DocItem = Text | Table | Link | Action | Macro | Header


pub struct Text{
pub mut:
	content string
}

pub struct Table{
pub mut:
	content string
}

pub struct Action{
pub mut:
	content string
}

pub struct Macro{
pub mut:
	content string
}

pub struct Header{
pub mut:
	content string
}