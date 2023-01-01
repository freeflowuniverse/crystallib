module model

pub struct Base {
pub mut:
	name        string [tag;index]
	description string
	remarks		string 
	timestamp_creation u32
	timestamp_modified u32 
	guid		string
}

