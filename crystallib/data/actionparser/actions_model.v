module actionparser

// import freeflowuniverse.crystallib.data.paramsparser
// import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.baobab.smartid

pub struct ActionsCollection {
pub mut:
	actions []Action
	othertext string //in case there is text outside of the actions
}



pub fn (collection ActionsCollection) str2() string {
	mut out := ''
	for action in collection.actions{
		out+="${action}\n"
	}

	out+= "OTHERTEXT:\n${collection.othertext}"

	return out
}

// serialize to 3script
pub fn (collection ActionsCollection) script3() string {
	mut out := ''
	for action in collection.actions{
		out+="${action.script3()}\n"
	}
	if collection.othertext.len>0{
		out+="${collection.othertext}"
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

