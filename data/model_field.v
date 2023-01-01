module data

pub struct Field{
pub mut:
	ispub bool =true //needs to be filled in
	ismut bool =true
	name string
	name_lower string
	typestr string
	tag bool
	index bool
	strskip bool
	comments string
}

