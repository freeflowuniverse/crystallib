module generic

import time


pub struct Base {
pub mut:

	name string 
	description string 
	remarks string 
	timestamp_creation time.Time 
	timestamp_modified time.Time 
	guid string 
}

