module herocmds

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.core.playcmds
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal.vscode
import cli { Command, Flag }
import os

pub fn cmd_run_add_flags(mut cmd_run Command) {
	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'path'
		abbrev: 'p'
		description: 'path where 3scripts can be found.'
	})
	// cmd_run.add_flag(Flag{
	// 	flag: .string
	// 	required: false
	// 	name: 'circle'
	// 	abbrev: 'c'
	// 	description: 'circle id or circle name.'
	// })
	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'sessionname'
		abbrev: 'sn'
		description: 'name for the session (optional).'
	})
	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'contextname'
		abbrev: 'cn'
		description: 'name for the context (optional).'
	})
	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'url'
		abbrev: 'u'
		description: 'url where 3script can be found.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'gitpull'
		abbrev: 'gp'
		description: 'will try to pull.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'gitreset'
		abbrev: 'gr'
		description: 'will reset the git repo if there are changes inside, will also pull, CAREFUL.'
	})

	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'coderoot'
		abbrev: 'cr'
		description: 'Set code root for gittools.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		name: 'script'
		abbrev: 's'
		description: 'runs non interactive!'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		name: 'reset'
		abbrev: 'r'
		description: 'reset, means lose changes of your repos, BE CAREFUL.'
	})


	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'edit'
		abbrev: 'e'
		description: 'Open visual studio code for where we found the content.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'sourcetree'
		abbrev: 'st'
		description: 'Open sourcetree (git mgmt) for the repo where we found the content.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'run'
		abbrev: 'r'
		description: 'Run the actions as found in the content.'
	})	

}

//returns the session and the path of the fetched repo
fn session_get(cmd Command) !(play.Session,get_string) {	

	//TODO: need to use gitstructure in session !!!

	mut path := cmd.flags.get_string('path') or { '' }
	mut url := cmd.flags.get_string('url') or { '' }

	mut sessionname := cmd.flags.get_string('sessionname') or { '' }
	mut contextname := cmd.flags.get_string('contextname') or { '' }

	mut coderoot := cmd.flags.get_string('coderoot') or { '' }
	if 'CODEROOT' in os.environ() && coderoot == '' {
		coderoot = os.environ()['CODEROOT']
	}

	reset := cmd.flags.get_bool('gitreset') or { false }
	pull := cmd.flags.get_bool('gitpull') or { false }
	interactive := !cmd.flags.get_bool('script') or { false }

	run := cmd.flags.get_bool('run') or { false }
	edit := cmd.flags.get_bool('edit') or { false }
	sourcetree := cmd.flags.get_bool('sourcetree') or { false }

	if url.len > 0 {
		path = gittools.code_get(
			coderoot: coderoot
			pull: pull
			reset: reset
			url: url
		)!
	}

	mut session := play.session_new(
		session_name: sessionname
		context_name: contextname
		coderoot: coderoot
		interactive: interactive
	)!

}


fn session_codetree_lib_run(cmd Command) !play.Session {

	if sourcetree {
		mut repo := gittools.git_repo_get(coderoot: coderoot, path: path)!
		repo.sourcetree()!
	} else if edit {
		vscode.open(path: path)!
	} else if run {
		// add all actions inside to the playbook
		session.playbook_add(path: path)!
		session.process()!
		console.print_stdout(session.plbook.str())
		playcmds.run(mut session)!
	} else {
		return error(cmd.help_message())
	}

	return session
}
