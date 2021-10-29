module taiga

import json
import time

struct Comment {
pub mut:
	description            string
	id                     int
	//TODO:
}

//return vlang time obj
pub fn (mut c Comment) created_date_get() time.Time {
	//panic if time doesn't work
	//make the other one internal, no reason to have the string public
	//do same for all dates
	panic("implement")
}

