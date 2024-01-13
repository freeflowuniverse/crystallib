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
		description: '
## Manage your MDBooks


example:

hero run -u https://git.ourworld.tf/threefold_coop/info_asimov/src/branch/main/script3 -r

The -r will run it, can also do -e or -st to see sourcetree

		
		'
		required_args: 0
		usage: ''
		execute: cmd_mdbook_execute
	}

	cmd_run_add_flags(mut cmd_mdbook)

	cmd_mdbook.add_flag(Flag{
		flag: .string
		name: 'name'
		abbrev: 'n'
		description: 'name of the mdbook.'
	})


	cmdroot.add_command(cmd_mdbook)
}

fn cmd_mdbook_execute(cmd Command) ! {
	mut name := cmd.flags.get_string('name') or { '' }
	mut run := cmd.flags.get_bool('run') or { false }
	mut sourcetree := cmd.flags.get_bool('sourcetree') or { false }
	mut edit := cmd.flags.get_bool('edit') or { false }
	mut edit := cmd.flags.get_bool('edit') or { false }

	if run{
		mut session:=session_codetree_lib_run(cmd)!
	}

	if cmd.name == 'edit' {
		mut book2 := mdbook.new_from_config(instance: name, reset: reset, context: &session.context)!
		book2.edit()!
	} else if cmd.name == 'open' {
		mut book2 := mdbook.new_from_config(instance: name, reset: reset, context: &session.context)!
		book2.generate()!
		book2.open()!
	} else if cmd.name == 'run' {
		cmd_3script_execute(cmd)!
		mut book2 := mdbook.new_from_config(instance: name, reset: reset, context: &session.context)!
		book2.generate()!
		book2.open()!
	} else {
		return error(cmd.help_message())
	}
}
