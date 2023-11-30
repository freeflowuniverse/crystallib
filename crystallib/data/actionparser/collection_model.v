module actionparser

// import freeflowuniverse.crystallib.data.paramsparser
// import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.baobab.smartid

pub struct ActionsCollection {
pub mut:
	actions   []Action
	othertext string // in case there is text outside of the actions
}

pub fn (collection ActionsCollection) str() string {
	// 	mut out := ''
	// 	for action in collection.actions{
	// 		out+="${action}\n"
	// 	}

	// 	out+= "OTHERTEXT:\n${collection.othertext}"

	// 	return out
	return collection.script3()
}

// serialize to 3script
pub fn (collection ActionsCollection) script3() string {
	mut out := ''
	for action in collection.actions {
		out += '${action.script3()}\n'
	}
	if collection.othertext.len > 0 {
		out += '${collection.othertext}'
	}

	return out
}

// return list of names .
// the names are normalized (no special chars, lowercase, ... )
pub fn (collection ActionsCollection) names() []string {
	mut names := []string{}
	for action in collection.actions {
		names << action.name
	}
	return names
}


[params]
pub struct ActionFindArg{
pub mut:
	name string
	actor string	
}

pub fn (collection ActionsCollection) exists(args ActionFindArg) bool {
	res:=collection.find(args)
	if res.len>0{
		return true
	}
	return false
}

pub fn (collection ActionsCollection) exists_once(args ActionFindArg) bool {
	res:=collection.find(args)
	if res.len==1{
		return true
	}
	return false
}

pub fn (collection ActionsCollection) get(args ActionFindArg) !Action {
	res:=collection.find(args)
	if res.len==1{
		return res[0]
	}
	return error("can't find action with args:$args")
}



pub fn (collection ActionsCollection) find(args ActionFindArg) []Action {
	mut res:=[]Action{}
	for action in collection.actions {
		mut found:=true
		if args.name!="" && action.name != args.name{
			found=false
		}
		if args.actor!="" && action.actor != args.actor{
			found=false
		}
		if found{
			res<< action
		}		

	}	
	return res

}