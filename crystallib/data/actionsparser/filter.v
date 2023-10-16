module actionsparser

import freeflowuniverse.crystallib.data.paramsparser

[params]
pub struct FilterArgs {
pub:
	domain       string = 'core'
	actor        string   // can be empty, this means will not filter based on actor
	circle       string   // can be empty, this means will not filter based on circle	
	names_filter []string // can be empty, then no filter, unix glob filters are allowed
}

// make sure that only actions are remembered linked to the actor or circle and also sorted in right order
// will also sort using the names filter
// args ActionsGetArgs:
//   actor    string [required]  //can be empty, this means will not filter based on actor
//   circle     string	[required]  //can be empty, this means will not filter based on circle	
//   names_filter    []string //can be empty, then no filter, unix glob filters are allowed
//
// return  []Action
pub fn (parser Actions) filtersort(args FilterArgs) ![]Action {
	mut result := []Action{}
	for action_ in parser.actions {
		mut action := action_
		if args.domain != '' && args.domain != action.domain {
			continue
		}
		if args.circle != '' && args.circle != '*' && args.circle != action.circle {
			continue
		}
		if args.actor != '' && args.actor != action.actor {
			continue
		}

		// if name filter is not set, just push to result
		if args.names_filter.len == 0 {
			result << action
			continue
		}

		mut prio := 0 // highest prio
		for name_filter in args.names_filter {
			if name_filter.contains('*') || name_filter.contains('?') || name_filter.contains('[') {
				if action.name.match_glob(name_filter) {
					action.priority = u8(prio)
					result << action
					continue
				} else if action.name == name_filter.to_lower() {
					action.priority = u8(prio)
					result << action
					continue
				}
			} else if action.name == name_filter.to_lower() {
				action.priority = u8(prio)
				result << action
				continue
			}
			prio += 1
		}
	}
	mut resultsorted := []Action{}

	// if name filter is not set, return unsorted
	if args.names_filter.len == 0 {
		return result
	}

	for prioselect in 0 .. args.names_filter.len {
		// walk over all prio's
		for action2 in result {
			if action2.priority == prioselect {
				resultsorted << action2
			}
		}
	}
	return resultsorted
}

// find 1 actions based on name, if 0 or more than 1 then error
pub fn (parser Actions) params_get(name string) !params.Params {
	mut result := []Action{}
	for action in parser.actions {
		if action.name == name.to_lower() {
			result << action
		}
	}
	if result.len == 0 {
		return error("could not find params from action with name:'${name}'")
	}
	if result.len > 1 {
		return error("found more than one action with name:'${name}'")
	}
	return result[0].params
}
