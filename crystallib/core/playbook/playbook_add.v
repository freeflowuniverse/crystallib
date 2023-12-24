module playbook

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.pathlib

@[params]
pub struct PLayBookAddArgs {
pub mut:
	path    string
	text    string
	prio    int   = 99
	execute bool
}

enum State {
	start
	comment_for_action_maybe
	action
	othertext
}

pub fn (mut plbook PlayBook) add(args_ PLayBookAddArgs)! {
	mut args := args_

	// println("PLBOOK ADD:\n$args_")

	//walk over directory
	if args.path.len > 0{
		mut p:=pathlib.get(args.path)
		if ! p.exists(){
			return error("can't find path:${p.path}")
		}
		if p.is_file(){
			c:=p.read()!
			plbook.add(text:c,execute:args.execute,prio:args.prio)!
			return
		}else if p.is_dir(){
			mut ol:=p.list(recursive:true,regex: [r'.*\.md$'])!
			for mut p2 in ol.paths{
				c2:=p2.read()!
				plbook.add(text:c2,execute:args.execute,prio:args.prio)!
			}
			return
		}
		return error("can't process path: ${args.path}, unknown type.")
	}	

	args.text = texttools.dedent(args.text)
	mut state := State.start

	mut action := &Action{}
	mut comments := []string{}
	mut paramsdata := []string{}

	for line_ in args.text.split_into_lines() {
		line := line_.replace('\t', '    ')
		line_strip := line.trim_space()

		if line_strip.len==0{
			continue
		}

		// println(" - state:${state} action:'${action.name}' comments:'${comments.len}' -> '${line}'")

		if state == .action {
			if !line.starts_with('  ') || line_strip == '' || line_strip.starts_with('!') {
				state = .start
				// means we found end of action
				action.params = paramsparser.new(paramsdata.join('\n'))!
				action.params.delete("id")
				comments = []string{}
				paramsdata = []string{}
				action = &Action{}
				// println(' - action end')
			} else {
				paramsdata << line_strip
			}
		}

		if state == .comment_for_action_maybe {
			if line.starts_with('//') {
				comments << line_strip.trim_left('/ ')
			}else{				
				if line_strip.starts_with('!') {
					// we are at end of comment
					state = .start
				} else {
					state = .start
					plbook.othertext += comments.join('\n')
					if !plbook.othertext.ends_with('\n') {
						plbook.othertext += '\n'
					}
					comments = []string{}
				}

			}
		}

		if state == .start {
			if line_strip.starts_with('!') && !line_strip.starts_with('![') {
				// start with new action
				state = .action				
				action = plbook.action_new(
					priority: args.prio
					execute: args.execute
				)
				action.comments = comments.join('\n')
				comments = []string{}
				paramsdata = []string{}
				mut actionname := line
				if line_strip.contains(" "){
					actionname=line_strip.all_before(' ').trim_space()
					paramsdata << line_strip.all_after_first(' ').trim_space()
				}				
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
					print_backtrace()
					panic('bug')
				}
				actionname = actionname.trim_left('!')
				splitted := actionname.split('.')
				if splitted.len == 1 {
					action.actor = "core"
					action.name = texttools.name_fix(splitted[0])
				} else if splitted.len == 2 {
					action.actor = texttools.name_fix(splitted[0])
					action.name = texttools.name_fix(splitted[1])
				} else {
					print_backtrace()
					return error('for now we only support actions with 1 or 2 parts.\n${actionname}')
				}
				// println(' - action new: ${action.actor}:${action.name} params:${paramsdata}')
				continue
			} else if line.starts_with('//') {
				state = .comment_for_action_maybe
				comments << line_strip.trim_left('/ ')
			} else {
				plbook.othertext += '${line_strip}\n'
			}
		}
	}
	// process the last one
	if state == .action {
		if action.id!=0{
			action.params = paramsparser.new(paramsdata.join('\n'))!
			action.params.delete("id")
		}
	}
	if state == .comment_for_action_maybe {
		plbook.othertext += comments.join('\n')
	}
	// if state == .start{
	// 	plbook.othertext+=line_strip
	// }	



}
