module actionsparser

[params]
pub struct FilterArgs {
pub:
	domain       string = 'protocol_me'
	actor        string   [required] // can be empty, this means will not filter based on actor
	book         string   [required] // can be empty, this means will not filter based on book	
	names_filter []string // can be empty, then no filter, unix glob filters are allowed
}

// make sure that only actions are remembered linked to the actor or book and also sorted in right order
// will also sort using the names filter
// args ActionsGetArgs:
//   actor    string [required]  //can be empty, this means will not filter based on actor
//   book     string	[required]  //can be empty, this means will not filter based on book	
//   names_filter    []string //can be empty, then no filter, unix glob filters are allowed
//
// return  []Action
pub fn filtersort(actions []Action, args FilterArgs) ![]Action {
	mut result := []Action{}
	for mut action in actions.actions {
		if args.domain != '' && args.domain != action.domain {
			continue
		}
		if args.book != '' && args.book != action.book {
			continue
		}
		if args.actor != '' && args.actor != action.actor {
			continue
		}
		action.name = action.name.to_lower().trim_space()

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
			}
			prio += 1
		}
	}
	mut resultsorted := []Action{}
	for prioselect in 0 .. args.names_filter.len {
		// walk over all prio's
		for action2 in actions.actions {
			if action2.priority == prioselect {
				resultsorted << action2
			}
		}
	}
	return resultsorted
}
