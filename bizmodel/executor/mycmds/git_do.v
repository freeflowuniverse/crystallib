module mycmds

import freeflowuniverse.crystallib.gittools
import cli { Command,Flag }

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
pub fn cmd_git_actions(mut cmdroot Command){
	mut cmd_run := Command{
		name: 'git_do'
		description: 'List all the repos and their status, you can also use this to commit, pull, push or reset'
		required_args: 0
		usage:'url_of_git_repo'
		execute: cmd_gitactions_execute
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
		abbrev: 'cr'
		description: 'reset the cache of the repos, they are kept for 24h'
	})


	cmdroot.add_command(cmd_run)		
}

fn cmd_gitactions_execute(cmd Command) ! {
	coderoot:=cmd.flags.get_string('coderoot') or {""}	
	
	if cmd.flags.get_bool('cachereset') or {false}{
		gittools.cachereset()!
	}

	mut gs := gittools.get(root:coderoot,create:true) or {return error("Could not find gittools on '${coderoot}'")}
	gs.actions(
			filter:cmd.flags.get_string('filter') or {""}
			repo:cmd.flags.get_string('repo') or {""}
			account:cmd.flags.get_string('account') or {""}
			provider:cmd.flags.get_string('provider') or {""}
			pull:cmd.flags.get_bool('pull') or {false}	
			pullreset:cmd.flags.get_bool('pullreset') or {false}
			commit:cmd.flags.get_bool('commit') or {false}
			commitpull:cmd.flags.get_bool('commitpull') or {false}
			commitpullpush:cmd.flags.get_bool('commitpullpush') or {false}
			delete:cmd.flags.get_bool('delete') or {false}
			script:cmd.flags.get_bool('script') or {false}
		)!
}