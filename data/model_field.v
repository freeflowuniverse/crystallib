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
	modellocation string
	crtype CRType
	
}


pub fn (mut f Field) comments_str() string{
	if f.comments.len==0{
		return ""
	}
	return "//${f.comments}"
}


