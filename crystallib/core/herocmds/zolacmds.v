module herocmds

import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.osal.zola
import cli { Command, Flag }

// path string //if location on filessytem, if exists, this has prio on git_url
// git_url   string // location of where the hero scripts are
// git_pull     bool // means when getting new repo will pull even when repo is already there
// git_pullreset bool // means we will force a pull and reset old content
// coderoot string //the location of coderoot if its another one
pub fn cmd_zola(mut cmdroot Command) {
	mut cmd_zola := Command{
		name: 'zola'
		description: ''
		required_args: 0
		usage: ''
	}

	mut cmd_zola_run := Command{
		name: 'run'
		description: 'run actions from 3script'
		required_args: 0
		usage: ''
		execute: cmd_zola_execute
	}
	cmds_run_add(mut cmd_zola_run) // add the run command as sub to the zola

	mut cmd_zola_open := Command{
		name: 'open'
		description: 'open specified website (in browser)'
		required_args: 0
		usage: ''
		execute: cmd_zola_execute
	}

	mut cmd_zola_edit := Command{
		name: 'edit'
		description: 'edit specified website (in vscode)'
		required_args: 0
		usage: ''
		execute: cmd_zola_execute
	}

	mut urlcmds := [&cmd_zola_open, &cmd_zola_edit]
	for mut c in urlcmds {
		c.add_flag(Flag{
			flag: .string
			required: true
			name: 'name'
			abbrev: 'n'
			description: 'name of the website.'
		})

		c.add_flag(Flag{
			flag: .bool
			name: 'reset'
			abbrev: 'r'
			description: 'reset, means lose changes of your repos.'
		})

		c.add_flag(Flag{
			flag: .string
			required: false
			name: 'context'
			abbrev: 'cn'
			description: 'name for the context (optional).'
		})
	}
	cmd_zola.add_command(cmd_zola_run)
	cmd_zola.add_command(cmd_zola_open)
	cmd_zola.add_command(cmd_zola_edit)

	cmdroot.add_command(cmd_zola)
}

fn cmd_zola_execute(cmd Command) ! {
	mut name := cmd.flags.get_string('name')!
	mut context := cmd.flags.get_string('context') or { '' }
	mut reset := cmd.flags.get_bool('reset') or { false }

	mut session := play.session_new(
		context_name: context
		interactive: true
	)!
	panic('implement')
	// if cmd.name == 'edit' {	
	// 	mut wsite2 := zola.new_from_config(instance: name, reset: reset, context: &session.context)!
	// 	wsite2.edit()!
	// }else if cmd.name == 'open' {
	// 	mut wsite2 := zola.new_from_config(instance: name, reset: reset, context: &session.context)!
	// 	wsite2.generate()!
	// 	wsite2.open()!
	// }else if cmd.name == 'run'{
	// 	cmd_3script_execute(cmd)!
	// 	mut wsite2 := zola.new_from_config(instance: name, reset: reset, context: &session.context)!
	// 	wsite2.generate()!
	// 	wsite2.open()!
	// }else{
	// 	return error(cmd.help_message())
	// }
}
