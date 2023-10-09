module mycmds

import freeflowuniverse.crystallib.osal.gittools
import cli { Command, Flag }

// const wikipath = os.dir(@FILE) + '/wiki'

pub fn cmd_git_get(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'git_get'
		description: 'Get git repo, use https:// or git... to a git repo, will try to load you ssh-key'
		required_args: 1
		usage: 'url_of_git_repo'
		execute: cmd_git_get_execute
	}

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'pull'
		abbrev: 'p'
		description: 'will pull the git info if it didn`t exist yet.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'reset'
		abbrev: 'r'
		description: 'will reset the git repo if there are changes inside, CAREFUL.'
	})

	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'coderoot'
		abbrev: 'cr'
		description: 'If you want to use another directory for your code root.'
	})

	cmdroot.add_command(cmd_run)
}

fn cmd_git_get_execute(cmd Command) ! {
	// mut gs := gittools.new()!
	url := cmd.args[0] or { panic('cannot find args for code_get') }
	r := gittools.code_get(
		url: url
		root: cmd.flags.get_string('coderoot') or { '' }
		pull: cmd.flags.get_bool('pull') or { false }
		reset: cmd.flags.get_bool('reset') or { false }
	)!

	println("Pulled code from '${url}'\nCan be found in: '${r}'")
}
