module usermanager



pub struct Group {
pub mut:

	name string 
	description string 
	remarks string 
	timestamp_creation time.Time 
	timestamp_modified time.Time 
	guid string 
	users []u32 
}

