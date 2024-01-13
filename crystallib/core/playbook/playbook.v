module playbook

// import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.core.smartid
import freeflowuniverse.crystallib.ui.console
import crypto.blake2b

pub struct PlayBook {
pub mut:
	actions    []&Action
	priorities map[int][]int
	othertext  string // in case there is text outside of the actions
	nractions  int
	done       []int // which actions did we already find
}

@[params]
pub struct ActionNewArgs {
pub mut:
	cid        string
	name       string
	actor      string
	priority   int  = 10 // 0 is highest, do 10 as default
	execute    bool = true // certain actions can be defined but meant to be executed directly
	actiontype ActionType
}

// add action to the book
fn (mut plbook PlayBook) action_new(args ActionNewArgs) &Action {
	plbook.nractions += 1
	mut a := Action{
		id: plbook.nractions
		cid: args.cid
		name: args.name
		actor: args.actor
		priority: args.priority
		execute: args.execute
		actiontype: args.actiontype
	}
	plbook.actions << &a
	return &a
}

pub fn (mut plbook PlayBook) str() string {
	return plbook.script3() or { 'Cannot visualize playbook properly.\n${plbook.actions}' }
}

@[params]
pub struct SortArgs {
pub mut:
	filtered bool // if true only show the actions which were filtered
}

pub fn (mut plbook PlayBook) actions_sorted(args SortArgs) ![]&Action {
	mut res := []&Action{}
	mut nrs := plbook.priorities.keys()
	nrs.sort()
	for nr in nrs {
		action_ids := plbook.priorities[nr] or { panic('bug') }
		for id in action_ids {
			mut a := plbook.action_get(id)!
			res << a
		}
	}
	assert plbook.done.len == res.len // amount in done and in priorities should be same

	if args.filtered {
		return res
	}

	for action in plbook.actions {
		if action.id !in plbook.done {
			res << action
		}
	}

	return res
}

@[params]
pub struct Script3Args {
	show_done bool = true
}

// serialize to 3script
pub fn (mut plbook PlayBook) script3(args Script3Args) !string {
	mut out := ''
	for action in plbook.actions_sorted()! {
		if args.show_done == false && action.done {
			continue
		}
		out += '${action.script3()}\n'
	}
	if plbook.othertext.len > 0 {
		out += '${plbook.othertext}'
	}
	out = texttools.remove_empty_js_blocks(out)
	return out
}

// return list of names .
// the names are normalized (no special chars, lowercase, ... )
pub fn (mut plbook PlayBook) names() ![]string {
	mut names := []string{}
	for action in plbook.actions_sorted()! {
		names << action.name
	}
	return names
}

pub fn (plbook PlayBook) action_exists(id int) bool {
	for a in plbook.actions {
		if a.id == id {
			return true
		}
	}
	return false
}

@[params]
pub struct ActionGetArgs {
pub mut:
	actor string
	name  string
}

pub fn (plbook PlayBook) action_exists_once(args ActionGetArgs) bool {
	mut counter := 0
	for a in plbook.actions {
		if a.actor == args.actor && a.name == args.name {
			counter += 1
		}
	}
	return counter == 1
}

pub fn (mut plbook PlayBook) action_get_by_name(args ActionGetArgs) !&Action {
	for a in plbook.actions {
		if a.actor == args.actor && a.name == args.name {
			return a
		}
	}
	return error("couldn't find action with args:${args}")
}

pub fn (mut plbook PlayBook) actions_find_by_name(args ActionGetArgs) ![]&Action {
	mut res := []&Action{}
	for a in plbook.actions {
		if a.actor == args.actor && a.name == args.name {
			res << a
		}
	}
	return res
}

pub fn (mut plbook PlayBook) action_get(id int) !&Action {
	for a in plbook.actions {
		if a.id == id {
			return a
		}
	}
	return error("can't find action with id:${id}")
}

pub fn (plbook PlayBook) hashkey() string {
	mut out := []string{}
	for action in plbook.actions {
		out << action.hashkey()
	}
	txt := out.join_lines()
	bs := blake2b.sum160(txt.bytes())
	return bs.hex()
}

// check if playbook is empty,if not will give error, means there are actions left to be exected
pub fn (mut plbook PlayBook) empty_check() ! {
	mut actions := []&Action{}
	for a in plbook.actions {
		if a.done == false {
			actions << a
		}
	}
	if actions.len > 0 {
		msg := plbook.script3(show_done: false)!
		return error('There are actions left to execute.\n\n${msg}')
	}
}
