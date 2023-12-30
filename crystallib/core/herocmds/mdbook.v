module herocmds

import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.osal.mdbook
import cli { Command, Flag }

// path string //if location on filessytem, if exists, this has prio on git_url
// git_url   string // location of where the hero scripts are
// git_pull     bool // means when getting new repo will pull even when repo is already there
// git_pullreset bool // means we will force a pull and reset old content
// coderoot string //the location of coderoot if its another one
pub fn cmd_mdbook(mut cmdroot Command) {
	mut cmd_mdbook := Command{
		name: 'mdbook'
		description: ''
		required_args: 0
		usage: ''
		execute: cmd_mdbook_execute
	}

	cmd_run(mut cmd_mdbook) // add the run command as sub to the mdbook

	mut cmd_mdbook_open := Command{
		name: 'open'
		description: 'open specified mdbook (in browser)'
		required_args: 0
		usage: ''
		execute: cmd_mdbook_execute
	}

	mut cmd_mdbook_edit := Command{
		name: 'edit'
		description: 'edit specified mdbook (in vscode)'
		required_args: 0
		usage: ''
		execute: cmd_mdbook_execute
	}

	mut urlcmds := [&cmd_mdbook_open, &cmd_mdbook_edit]
	for mut c in urlcmds {
		c.add_flag(Flag{
			flag: .string
			required: true
			name: 'name'
			abbrev: 'n'
			description: 'name of the mdbook.'
		})

		c.add_flag(Flag{
			flag: .bool
			name: 'reset'
			abbrev: 'r'
			description: 'reset, means lose changes of your repos.'
		})

		cmd_mdbook.add_flag(Flag{
			flag: .string
			required: false
			name: 'context'
			abbrev: 'cn'
			description: 'name for the context (optional).'
		})
	}

	cmdroot.add_command(cmd_mdbook)
	cmd_mdbook.add_command(cmd_mdbook_open)
	cmd_mdbook.add_command(cmd_mdbook_edit)
}

fn cmd_mdbook_execute(cmd Command) ! {
	mut name := cmd.flags.get_string('name')!
	mut context := cmd.flags.get_string('context') or { '' }
	mut reset := cmd.flags.get_bool('reset') or { false }

	mut session := play.session_new(
		context_name: context
		interactive: true
	)!

	if cmd.name == 'edit' {
		// little bit hackish for now, in future need to use the KVS in the context		
		mut book2 := mdbook.new_from_config(instance: name, reset: reset, context: &session.context)!
		book2.edit()!
	}

	if cmd.name == 'open' {
		mut book2 := mdbook.new_from_config(instance: name, reset: reset, context: &session.context)!
		book2.generate()!
		book2.edit()!
	}
}
