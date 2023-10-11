module mycmds

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.osal
import cli { Command, Flag }
import os


// path string //if location on filessytem, if exists, this has prio on git_url
// git_url   string // location of where the hero scripts are
// git_pull     bool // means when getting new repo will pull even when repo is already there
// git_pullreset bool // means we will force a pull and reset old content
// coderoot string //the location of coderoot if its another one
pub fn cmd_git_do(mut cmdroot Command) {
	mut cmd_run := Command{
		name: '3script'
		description: ''
		required_args: 0
		usage: ''
		execute: cmd_3script_execute
	}
	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'path'
		abbrev: 'p'
		description: 'path where 3script can be found.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'git_pull'
		abbrev: 'p'
		description: 'will pull the content, if it exists for each found repo.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'git_pullreset'
		abbrev: 'pr'
		description: 'will reset the git repo if there are changes inside, CAREFUL.'
	})


	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'editor'
		abbrev: 'code'
		description: 'Open visual studio code for where we found the 3script.'
	})

	cmdroot.add_command(cmd_run)
}

fn cmd_3script_execute(cmd Command) ! {
	coderoot := cmd.flags.get_string('coderoot') or { '' }

	mut gs := gittools.get(root: coderoot, create: true) or {
		return error("Could not find gittools on '${coderoot}'\n${err}")
	}

	//TODO: all below needs to be adjusted
	// USE freeflowuniverse/crystallib/crystallib/baobab/hero/runner.v to execute 

	mut repo := cmd.flags.get_string('repo') or { '' }
	mut account := cmd.flags.get_string('account') or { '' }
	mut provider := cmd.flags.get_string('provider') or { '' }
	mut filter := cmd.flags.get_string('filter') or { '' }
	if repo == '' && account == '' && provider == '' && filter == '' {
		curdir := os.getwd()
		if os.exists('${curdir}/.git') {
			// we are in current directory
			r0 := gs.repo_from_path(curdir)!
			repo = r0.addr.name
			account = r0.addr.account
			provider = r0.addr.provider
		}
	}

	gs.do(
		filter: cmd.flags.get_string('filter') or { '' }
		repo: repo
		account: account
		provider: provider
		pull: cmd.flags.get_bool('pull') or { false }
		pullreset: cmd.flags.get_bool('pullreset') or { false }
		commit: cmd.flags.get_bool('commit') or { false }
		commitpull: cmd.flags.get_bool('commitpull') or { false }
		commitpullpush: cmd.flags.get_bool('commitpullpush') or { false }
		delete: cmd.flags.get_bool('delete') or { false }
		script: cmd.flags.get_bool('script') or { false }
		cachereset: cmd.flags.get_bool('cachereset') or { false }
		msg: cmd.flags.get_string('message') or { '' }
	)!

	editor := cmd.flags.get_bool('editor') or { false }
	sourcetree := cmd.flags.get_bool('sourcetree') or { false }
	if sourcetree || editor {
		repos := gs.repos_get(
			filter: cmd.flags.get_string('filter') or { '' }
			name: repo
			account: account
			provider: provider
		)
		if repos.len > 5 {
			return error("Can only open sourcetree or code editor for max 5 repo's")
		}
		for r in repos {
			if editor {
				cmd3 := "open -a \"Visual Studio Code\" ${r.path.path}"
				osal.execute_interactive(cmd3) or { panic(err) }
			}
			if sourcetree {
				cmd4 := 'open -a SourceTree ${r.path.path}'
				println(cmd4)
				osal.execute_interactive(cmd4) or { panic(err) }
			}
		}
	}
}
