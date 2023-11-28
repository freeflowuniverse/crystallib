module herocmds

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.osal
import cli { Command, Flag }
import os
// const wikipath = os.dir(@FILE) + '/wiki'

// filter   string // if used will only show the repo's which have the filter string inside
// repo     string
// account  string
// provider string
// pull     bool // means when getting new repo will pull even when repo is already there
// pullreset bool // means we will force a pull and reset old content	
// commit bool
// commitpush bool
// commitpullpush bool
// message string
// delete bool (remove the repo)
// script bool (run non interactive)
// coderoot string //the location of coderoot if its another one
// cachereset, make sure cache empty
pub fn cmd_git_do(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'git'
		description: 'Work with your repos, list, commit, pull, reset, ...'
		required_args: 0
		usage: ''
		execute: cmd_git_do_execute
	}

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'pull'
		abbrev: 'p'
		description: 'will pull the content, if it exists for each found repo.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'pullreset'
		abbrev: 'pr'
		description: 'will reset the git repo if there are changes inside, CAREFUL.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'delete'
		abbrev: 'd'
		description: 'delete the repo.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'commit'
		abbrev: 'c'
		description: 'will commit newly found content, specify the message.'
	})
	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'commitpull'
		abbrev: 'cp'
		description: 'commit and pull.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'commitpullpush'
		abbrev: 'cpp'
		description: 'commit,pull and push.'
	})

	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'message'
		abbrev: 'm'
		description: 'which message to use for commit.'
	})

	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'coderoot'
		abbrev: 'cr'
		description: 'If you want to use another directory for your code root.'
	})

	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'filter'
		abbrev: 'f'
		description: 'Filter is part of path of repo e.g. threefoldtech/info_'
	})

	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'repo'
		abbrev: 'r'
		description: 'name of repo'
	})

	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'account'
		abbrev: 'a'
		description: 'name of account e.g. threefoldtech'
	})

	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'provider'
		abbrev: 'p'
		description: 'name of provider e.g. github'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'script'
		description: 'script way, will not run interative'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'cachereset'
		abbrev: 'l'
		description: 'reset the cache of the repos, they are kept for 24h'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'sourcetree'
		abbrev: 'ui'
		description: 'Open sourcetree on found repos, will do for max 5.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'editor'
		abbrev: 'code'
		description: 'Open visual studio code on found repos, will do for max 5.'
	})

	cmdroot.add_command(cmd_run)
}

fn cmd_git_do_execute(cmd Command) ! {
	coderoot := cmd.flags.get_string('coderoot') or { '' }

	mut gs := gittools.get(coderoot: coderoot) or {
		return error("Could not find gittools on '${coderoot}'\n${err}")
	}

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

	// high level interface as done on gitstructure to execute on the cmds above
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
