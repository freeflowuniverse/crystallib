module herocmds

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

hero mdbook -u https://git.ourworld.tf/threefold_coop/info_asimov/src/branch/main/script3

If you do -gp it will pull newest book content from git and give error if there are local changes.
If you do -gr it will pull newest book content from git and overwrite local changes (careful).

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
	mut session, _ := session_run_do(cmd)!

	mut name := cmd.flags.get_string('name') or { '' }

	if name == '' {
		mut a := session.plbook.action_get_by_name(actor: 'book', name: 'define')!
		name = a.params.get('name') or { '' }
	}

	if name == '' {
		println('did not find defined book, or name not specified')
		return error(cmd.help_message())
	}

	reset := cmd.flags.get_bool('gitreset') or { false }

	mut book2 := mdbook.new_from_config(instance: name, reset: reset, context: &session.context)!

	book2.generate()!
	book2.open()!

	edit := cmd.flags.get_bool('edit') or { false }

	if edit {
		book2.edit()!
	}
}
