module actionsparser

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.baobab.smartid
[params]
pub struct FilterArgs {
pub:
	cids         []smartid.CID
	actor_names  []string
	action_names []string
}

[params]
pub struct FilterSortArgs {
pub:
	priorties map[u8]FilterArgs // filter and give priority
}

// filter actions based on the criteria
//```
// args ActionsGetArgs:
// cid          []u32 		//if empty will match all
// actor_names  []string 	//if empty will match all,
// action_names []string 	//if empty will match all
//```
// the action_names or actor_names can be a glob in match_glob .
// see https://modules.vlang.io/index.html#string.match_glob .
// return  []Action
pub fn (actions Actions) filter(args FilterArgs) Actions {
	mut result := Actions{}
	result.items = []Action{}
	for action in actions.items {
		if action.checkmatch(args) == false {
			continue
		}
		result.items << action
	}
	return result
}

// filter actions based on the criteria
//```
// struct  FilterArgs:
//   cid          []u32 		//if empty will match all
//   actor_names  []string 	//if empty will match all,
//   action_names []string 	//if empty will match all
//
// struct FilterSortArgs {
// 	 priorties  map[u8]FilterArgs //filter and give priority
//```
// the action_names or actor_names can be a glob in match_glob .
// see https://modules.vlang.io/index.html#string.match_glob .
// the highest priority will always be chosen . (it can be a match happens 2x)
// return  []Action
pub fn (actions Actions) filtersort(args FilterSortArgs) Actions {
	mut result := map[u8][]Action{}
	mut done := []string{}

	for prio, argsfilter in args.priorties {
		for mut actionfiltered in actions.filter(argsfilter).items {
			actionfiltered.priority = prio
			if prio !in result {
				result[prio] = []Action{}
			}
			result[prio] << actionfiltered
		}
	}
	// lets now fill in the result
	mut resultsorted := Actions{}
	resultsorted.items = []Action{}

	mut prios := result.keys()
	prios.sort()
	for prio in prios {
		for action in result[prio] {
			resultsorted.items << action
		}
	}
	return resultsorted
}

// check if the action matches following the filter args .
// the action_names or actor_names can be a glob in match_glob .
// see https://modules.vlang.io/index.html#string.match_glob
fn (action Action) checkmatch(args FilterArgs) bool {
	mut ok := true
	if args.cids.len > 0 {
		ok = false
		for cid in args.cids {
			if cid.circle == action.cid.circle {
				ok = true
			}
		}
		if ok == false {
			return false
		}
	}
	if args.actor_names.len > 0 {
		ok = false
		for actorname in args.actor_names {
			if actorname.contains('*') || actorname.contains('?') || actorname.contains('[') {
				if action.actor.match_glob(actorname) {
					ok = true
				} else if action.actor == actorname.to_lower() {
					ok = true
				}
			}
		}
		if ok == false {
			return false
		}
	}
	if args.action_names.len > 0 {
		ok = false
		for actionname in args.action_names {
			if actionname.contains('*') || actionname.contains('?') || actionname.contains('[') {
				if action.name.match_glob(actionname) {
					ok = true
				} else if action.name == actionname.to_lower() {
					ok = true
				}
			}
		}
		if ok == false {
			return false
		}
	}
	return true
}

// find all relevant actions, return the params out of one
pub fn (actions Actions) params_get(args FilterArgs) !paramsparser.Params {
	mut result := actions.filter(args)
	mut paramsresult := paramsparser.new("")!
	for action in result.items {
		paramsresult.merge(action.params)!
	}
	return paramsresult
}



//TODO: need tests for the sorted filtering