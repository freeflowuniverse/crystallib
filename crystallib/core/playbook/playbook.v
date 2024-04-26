module playbook

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser
import crypto.blake2b

pub struct PlayBook {
pub mut:
	actions    []&Action
	priorities map[int][]int // first key is the priority, the list of int's is position in list self.actions
	othertext  string        // in case there is text outside of the actions
	nractions  int
	done       []int // which actions did we already find/run?
	session    &base.Session
}

@[params]
pub struct ActionNewArgs {
pub mut:
	cid      string
	name     string
	actor    string
	priority int = 10 // 0 is highest, do 10 as default
	// run    bool = true // certain actions can be defined but meant to be executed directly
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
		// run: args.run
		actiontype: args.actiontype
		params: paramsparser.Params{}
		result: paramsparser.Params{}
	}
	plbook.actions << &a
	return &a
}

pub fn (mut plbook PlayBook) str() string {
	return plbook.heroscript() or { 'Cannot visualize playbook properly.\n${plbook.actions}' }
}

@[params]
pub struct SortArgs {
pub mut:
	prio_only bool // if true only show the actions which were prioritized before
}

// only return the actions which are not done  yet
// if filtered is set, it means we only get the ones which were prioritized before
pub fn (mut plbook PlayBook) actions_sorted(args SortArgs) ![]&Action {
	mut res := []&Action{}
	mut nrs := plbook.priorities.keys()
	nrs.sort()
	if nrs.len == 0 {
		// means sorting did not happen before
		return plbook.actions
	}
	for nr in nrs {
		if args.prio_only && nr > 49 {
			continue
		}
		action_ids := plbook.priorities[nr] or { panic('bug') }
		for id in action_ids {
			mut a := plbook.action_get(id)!
			res << a
		}
	}
	return res
}

@[params]
pub struct HeroScriptArgs {
pub mut:
	show_done bool = true
}

// serialize to heroscript
pub fn (mut plbook PlayBook) heroscript(args HeroScriptArgs) !string {
	mut out := ''
	for action in plbook.actions_sorted()! {
		if args.show_done == false && action.done {
			continue
		}
		out += '${action.heroscript()}\n'
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
		if args.actor.len > 0 && a.actor != args.actor {
			continue
		}
		if args.name.len > 0 && a.name != args.name {
			continue
		}
		res << a
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
		msg := plbook.heroscript(show_done: false)!
		return error('There are actions left to execute, see below:\n\n${msg}\n\n')
	}
}
