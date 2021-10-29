module taiga

import json
import time

//is what is used to query
//we need to rework the other ones the same
//they have the raw data, then you process to go from raw to the usable one in vlang
struct CommentRaw {
mut:
	comment            string
	date               string
	// user			   UserRaw
	//TODO:
}

struct Comment {
pub mut:
	comment            string
	date               time.Time
	user			   &User
	//TODO:
}


//return vlang clean object
pub fn (mut c CommentRaw) get() Comment {
	mut conn := connection_get()
	//fill in times...
	//if other objects look for them and get reference to them
	//use conn.user_get(user_id) to get user  ...
	panic("implement")
}


