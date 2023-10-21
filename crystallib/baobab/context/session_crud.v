module context

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.core.texttools

// __global (
// 	dbs shared map[string]CircleDB
// )

// //unique per circle
// [heap]
// pub struct CircleDB {
// pub mut:
// 	sessions map[string]Session
// 	contexts map[string]Context
// }



// [params]
// pub struct ContextNewArgs {
// pub mut:
// 	id    string
// 	name  string
// 	start  string // can be e.g. +1h
// 	params ?paramsparser.Params
// }


pub session_get(cid string, id string) !Session {
	lock dbs {
		if !(cid  in dbs){
			dbs[cid] = CircleDB{}
		}
		mut db:=&dbs[cid]
		return  db.sessions[id] or {
			mut r := redisclient.core_get()!
			data := r.hget('db:${cid}:sessions', id) or {""}
			if data == '' {
				return Session{cid:cid} //id is empty this means new object
			}
			obj:=json.decode(Session,data) or {return error("Cannot decode session.\n$data")}
			db.sessions[id] = obj
			obj
		}
	}
}

pub session_set(session_ Session) ! {
	mut r := redisclient.core_get()!
	mut session:=session_
	if session.id == ""{
		session.id = ...
	}
	if session.cid == ""{
		panic("session cid should always be filled in. Bug.")
	}	
	lock dbs {
		if !(cid  in dbs){
			dbs[cid] = CircleDB{}
		}
		mut db:=&dbs[cid]
		data:=json.encode()
		r.hset('db:${cid}:sessions', id) or {""}
			if data == '' {
				return Session{cid:cid} //id is empty this means new object
			}
			obj:=json.decode(Session,data) or {return error("Cannot decode session.\n$data")}
			db.sessions[id] = obj
			obj
		}
	}
}




// get a context object based on the name /
// params:
//
// ```
// uid	string //unique id
// name string
// start string  //can be e.g. +1h
// ```
//
pub fn new(args_ ContextNewArgs) !&Context {
	mut args := args_
	args.id = texttools.name_fix(args.id)
	if args.id !in contexts {
		mut params_ := args.params or { paramsparser.Params{} }
		mut c := Context{
			id: args.id
			alias: args.alias
			start: ourtime.new(args.start)!
			params: params_
		}
}

[params]
pub struct GetArgs {
pub mut:
	id    string
	name  string
	start  string // can be e.g. +1h
	params ?paramsparser.Params
}


pub fn get(id string) !&Context {
	mut args := args_
	args.id = texttools.name_fix(args.id)
	if args.id !in contexts {
		mut params_ := args.params or { paramsparser.Params{} }
		mut c := Context{
			id: args.id
			alias: args.alias
			start: ourtime.new(args.start)!
			params: params_
		}
		lock contexts {
			contexts[args.id] = &c
		}
	}
	lock contexts {
		c:=contexts[args.id] or { return error('Could not find context ${args.id}') }
		return c
	}
	panic('bug')
}