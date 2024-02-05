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

hero mdbook -u https://git.ourworld.tf/tfgrid/info_tfgrid/src/branch/main/script3

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

	// cmd_mdbook.add_flag(Flag{
	// 	flag: .bool
	// 	required: false
	// 	name: 'edit'
	// 	description: 'will open vscode for collections & summary.'
	// })

	cmd_mdbook.add_flag(Flag{
		flag: .bool
		required: false
		name: 'open'
		abbrev: 'o'
		description: 'will open the generated book.'
	})

	cmdroot.add_command(cmd_mdbook)
}

fn cmd_mdbook_execute(cmd Command) ! {

	mut name := cmd.flags.get_string('name') or { '' }


	mut url := cmd.flags.get_string('url') or { '' }
	mut path := cmd.flags.get_string('path') or { '' }
	if path.len>0 || url.len>0 {

		//execute the attached playbook
		mut session, _ := session_run_do(cmd)!

		//get name from the book.generate action
		if name == '' {
			mut a := session.plbook.action_get_by_name(actor: 'book', name: 'generate')!
			name = a.params.get('name') or { '' }
		}

	}else{
		return error(cmd.help_message())
	}

	if name == '' {
		println('did not find name of book to generate, check in 3script or specify with --name')
		return error(cmd.help_message())
	}

	edit := cmd.flags.get_bool('edit') or { false }
	open := cmd.flags.get_bool('open') or { false }
	if edit || open {
		mdbook.book_open(name)!
	}

	if edit {
		mdbook.book_edit(name)!
	}

}
