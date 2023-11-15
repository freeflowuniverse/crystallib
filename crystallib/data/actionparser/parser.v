module actionparser

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser

[params]
pub struct ParserArgs {
pub:
	text    string
	execute bool = true
	prio    u8   = 10
}

// parse a text file to 1 action
pub fn parse(args ParserArgs) !Action {
	ac := parse_collection(args)!
	if ac.actions.len > 1 {
		return error('Found more than 1 action in ${args}')
	}
	return ac.actions[0]
}

enum State {
	start
	comment_for_action_maybe
	action
	othertext
}

// return strings which are found which are not actions
// return the actionscollection
pub fn parse_collection(args ParserArgs) !ActionsCollection {
	mut ac := ActionsCollection{}

	mut state := State.start

	mut action := Action{}
	mut comments := []string{}
	mut paramsdata := []string{}

	for line_ in args.text.split_into_lines() {
		line := line_.replace('\t', '    ')
		line_strip := line.trim_space()

		println(" - ${state} action:'${action.name}' comments:'${comments.len}' -> '${line}'")

		if state == .action {
			if !line.starts_with('  ') || line_strip == '' || line_strip.starts_with('!') {
				state = .start
				// means we found end of action
				action.params = paramsparser.new(paramsdata.join('\n'))!
				ac.actions << action
				comments = []string{}
				paramsdata = []string{}
				action = Action{}
				println(' - action end')
			} else {
				paramsdata << line_strip
			}
		}

		if state == .comment_for_action_maybe {
			if !(line.starts_with('//')) {
				if line_strip.starts_with('!') {
					// we are at end of comment
					state = .start
				} else {
					state = .start
					ac.othertext += comments.join('\n')
					if !ac.othertext.ends_with('\n') {
						ac.othertext += '\n'
					}
					comments = []string{}
				}
			}
		}

		if state == .start {
			if line_strip.starts_with('!') {
				state = .action

				// start with new action
				action = Action{
					priority: args.prio
					execute: args.execute
				}
				action.comments = comments.join('\n')
				comments = []string{}
				println(' - action new')
				println(' - comment delete')

				comments = []string{}
				mut actionname := line.all_before(' ').trim_space()
				if actionname.starts_with('!!!!!') {
					error('there is no action starting with 5 x !')
				} else if actionname.starts_with('!!!!') {
					action.actiontype = .macro
				} else if actionname.starts_with('!!!') {
					action.actiontype = .wal
				} else if actionname.starts_with('!!') {
					action.actiontype = .sal
				} else if actionname.starts_with('!') {
					action.actiontype = .dal
				} else {
					panic('bug')
				}
				actionname = actionname.trim_left('!')
				splitted := actionname.split('.')
				{
					if splitted.len == 1 {
						action.name = texttools.name_fix(splitted[0])
					} else if splitted.len == 2 {
						action.actor = texttools.name_fix(splitted[0])
						action.name = texttools.name_fix(splitted[1])
					} else {
						return error('for now we only support actions with 1 or 2 parts.\n${actionname}')
					}
				}
				paramsdata << line.all_after_first(' ').trim_space().trim_left('!')
				continue
			} else if line.starts_with('//') {
				state = .comment_for_action_maybe
				comments << line_strip.trim_left('/ ')
			} else {
				ac.othertext += '${line_strip}\n'
			}
		}
	}
	// process the last one
	if state == .action {
		action.params = paramsparser.new(paramsdata.join('\n'))!
		ac.actions << action
	}
	if state == .comment_for_action_maybe {
		ac.othertext += comments.join('\n')
	}
	// if state == .start{
	// 	ac.othertext+=line_strip
	// }	

	return ac
}
