module actionsparser

import math

// make sure that only actions are remembered linked to the actor or book and also sorted in right order
pub fn (mut actions ActionsParser) filter() ! {
	actions.filter_book()
	actions.filter_actor()
	actions.filter_actions()
	actions.unsorted = []Action{}
}

// removes in place actions for books excluding the provided book
// returns a list of 
fn (mut actions ActionsParser) filter_actor() {

	if actions.actor == '' {
		return
	}

	mut i := 0
	for {
		if i == actions.unsorted.len {
			break
		}

		action := actions.unsorted[i]
		prefix := action.name.all_before_last('.')
		actor := prefix.all_after_last('.')

		println('hereya: $i, $actor, $actions.actor')
		//todo: refactor
		if actor != actions.actor {
			println('skipped: $actor')
			actions.skipped << action
			actions.unsorted.delete(i)
		} else {
			i += 1
		}
	}
}

// removes in place actions for books excluding the provided book
// returns a list of 
fn (mut actions ActionsParser) filter_book() {
	for i, action in actions.unsorted {
		if action.name.starts_with(actions.book) {
			actions.skipped << action
			actions.unsorted.delete(i)
		}
	}
}

// removes in place actions for books excluding the provided book
// returns a list of 
fn (mut actions ActionsParser) filter_actions() {
	for i, action in actions.unsorted {
		if !actions.filter.contains(action.name) {
			actions.skipped << action
			actions.unsorted.delete(i)
		}
	}
	actions.ok = sort_actions(actions.filter, actions.unsorted)
}

fn sort_actions(filter []string, actions []Action) []Action {
	if actions.len > 1 {
		index := int(actions.len/2)
		a := sort_actions(filter, actions[..index])
		b := sort_actions(filter, actions[index..])
		return merge(a, b, filter)
	}
	return actions
}

fn merge(a []Action, b []Action, filters []string) []Action {
	mut i := 0
	mut j := 0
	mut sorted := []Action{}
	for i < a.len && j < b.len {
        if compare_order(a[i], b[j], filters) == -1 {
			sorted << a[i]
            i += 1
		} else if compare_order(a[i], b[j], filters) == 1 {
			sorted << b[j]
            j += 1
		} else {
			sorted << a[i]
			sorted << b[j]
			i += 1
			j += 1
		}
	}
	return sorted
}

// compares the order of two actions, returns 1,0,-1 accordingly
fn compare_order(a &Action, b &Action, filter []string) int {

	a_prefix := a.name.all_before_last('.')
	a_name := a_prefix.all_after_last('.')

	b_prefix := b.name.all_before_last('.')
	b_name := b_prefix.all_after_last('.')

	if filter.index(a_name) == -1 || filter.index(b_name) == -1 {
		return 0
	} else if filter.index(a_name) < filter.index(b_name) {
		return -1
	}

	return 1
}