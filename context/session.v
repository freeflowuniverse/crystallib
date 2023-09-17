module context

import freeflowuniverse.crystallib.ourtime


pub struct Session{
pub mut:
	sid	string //unique id for session (session id), there can be more than 1 per cid
	name string
	start 	ourtime.OurTime
	end ourtime.OurTime
}

[params]
pub struct SessionNewArgs{
pub mut:
	sid	string //unique id for session (session id), there can be more than 1 per cid
	name string
	start string //can be e.g. +1h
}


// get a session object based on the name /
// params:
//
// ```
// uid	string //unique id
// name string
// start string  //can be e.g. +1h
// ```
//
// pub fn get(args_ SessionNewArgs) !Session {
// 	mut args:=args_
// 	args.name=texttools.name_fix(args.name)
// 	rlock sessions {
// 		return sessions[args.name] or { return error('Could not find session ${args.name}') }
// 	}
// 	panic('bug')
// }

