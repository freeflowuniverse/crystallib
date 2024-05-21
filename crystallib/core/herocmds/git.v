module herocmds

import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.core.pathlib
import cli { Command, Flag }
import os
import crypto.md5

pub fn cmd_git(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'git'
		description: 'Work with your repos, list, commit, pull, reload, ...'
		// required_args: 1
		usage: 'sub commands of git are '
		execute: cmd_git_execute
		sort_commands: true
	}

	mut clone_command := Command{
		sort_flags: true
		name: 'clone'
		execute: cmd_git_execute
		description: 'will clone the repo based on a given url, e.g. https://github.com/freeflowuniverse/webcomponents/tree/main'
	}

	mut pull_command := Command{
		sort_flags: true
		name: 'pull'
		execute: cmd_git_execute
		description: 'will pull the content, if it exists for each found repo.'
	}

	mut push_command := Command{
		sort_flags: true
		name: 'push'
		execute: cmd_git_execute
		description: 'will push the content, if it exists for each found repo.'
	}

	mut commit_command := Command{
		sort_flags: true
		name: 'commit'
		execute: cmd_git_execute
		description: 'will commit newly found content, specify the message.'
	}

	mut reload_command := Command{
		sort_flags: true
		name: 'reload'
		execute: cmd_git_execute
		description: 'reset the cache of the repos, they are kept for 24h in local redis, this will reload all info.'
	}

	mut delete_command := Command{
		sort_flags: true
		name: 'delete'
		execute: cmd_git_execute
		description: 'delete the repo.'
	}

	mut list_command := Command{
		sort_flags: true
		name: 'list'
		execute: cmd_git_execute
		description: 'list all repos.'
	}

	mut sourcetree_command := Command{
		sort_flags: true
		name: 'sourcetree'
		execute: cmd_git_execute
		description: 'Open sourcetree on found repos, will do for max 5.'
	}

	mut editor_command := Command{
		sort_flags: true
		name: 'edit'
		execute: cmd_git_execute
		description: 'Open visual studio code on found repos, will do for max 5.'
	}

	mut allcmdsref := [&list_command, &clone_command, &push_command, &pull_command, &commit_command,
		&reload_command, &delete_command, &sourcetree_command, &editor_command]

	mut allcmdscommit := [&push_command, &pull_command, &commit_command]

	for mut c in allcmdscommit {
		c.add_flag(Flag{
			flag: .string
			required: false
			name: 'message'
			abbrev: 'm'
			description: 'which message to use for commit.'
		})
	}

	mut urlcmds := [&clone_command, &pull_command, &push_command, &editor_command, &sourcetree_command]
	for mut c in urlcmds {
		c.add_flag(Flag{
			flag: .string
			required: false
			name: 'url'
			abbrev: 'u'
			description: 'url for clone operation.'
		})
		c.add_flag(Flag{
			flag: .bool
			required: false
			name: 'pull'
			description: 'force a pull.'
		})
	}

	for mut c in allcmdsref {
		c.add_flag(Flag{
			flag: .string
			required: false
			name: 'filter'
			abbrev: 'f'
			description: 'Filter is part of path of repo e.g. threefoldtech/info_'
		})

		c.add_flag(Flag{
			flag: .string
			required: false
			name: 'repo'
			abbrev: 'r'
			description: 'name of repo'
		})

		c.add_flag(Flag{
			flag: .string
			required: false
			name: 'account'
			abbrev: 'a'
			description: 'name of account e.g. threefoldtech'
		})

		c.add_flag(Flag{
			flag: .string
			required: false
			name: 'provider'
			abbrev: 'p'
			description: 'name of provider e.g. github'
		})
	}
	for mut c_ in allcmdsref {
		mut c := *c_
		c.add_flag(Flag{
			flag: .string
			required: false
			name: 'coderoot'
			abbrev: 'cr'
			description: 'If you want to use another directory for your code root.'
		})
		c.add_flag(Flag{
			flag: .bool
			required: false
			name: 'script'
			abbrev: 'z'
			description: 'to use in scripts, will not run interative and ask questions.'
		})
		cmd_run.add_command(c)
	}

	cmdroot.add_command(cmd_run)
}

fn cmd_git_execute(cmd Command) ! {
	mut coderoot := cmd.flags.get_string('coderoot') or { '' }

	if 'CODEROOT' in os.environ() && coderoot == '' {
		coderoot = os.environ()['CODEROOT']
	}

	mut gs := gittools.get()!
	if coderoot.len > 0 {
		// when other coderoot, need to make sure we get a new name and make unique instance
		name := md5.hexhash(coderoot)
		gs = gittools.new(name: name, root: coderoot)!
	}

	// create the filter for doing group actions, or action on 1 repo
	mut filter := cmd.flags.get_string('filter') or { '' }
	mut repo := cmd.flags.get_string('repo') or { '' }
	mut account := cmd.flags.get_string('account') or { '' }
	mut provider := cmd.flags.get_string('provider') or { '' }

	// check if we are in a git repo
	if repo == '' && account == '' && provider == '' && filter == '' {
		curdir := os.getwd()
		mut curdiro := pathlib.get_dir(path: curdir, create: false)!
		mut parentpath := curdiro.parent_find('.git') or { pathlib.Path{} }
		if parentpath.path != '' {
			r0 := gs.repo_add(path: parentpath.path)!
			repo = r0.addr.name
			account = r0.addr.account
			provider = r0.addr.provider
		}
	}

	if cmd.name in gittools.gitcmds.split(',') {
		gs.do(
			filter: filter
			repo: repo
			account: account
			provider: provider
			cmd: cmd.name
			script: cmd.flags.get_bool('script') or { false }
			pull: cmd.flags.get_bool('pull') or { false }
			reset: cmd.flags.get_bool('reset') or { false }
			msg: cmd.flags.get_string('message') or { '' }
			url: cmd.flags.get_string('url') or { '' }
		)!
		return
	} else {
		// println(" Supported commands are: ${gittools.gitcmds}")
		return error(cmd.help_message())
	}
}
