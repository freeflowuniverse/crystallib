module herocmds

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.play

import cli { Command, Flag }
import os

// path string //if location on filessytem, if exists, this has prio on git_url
// git_url   string // location of where the hero scripts are
// git_pull     bool // means when getting new repo will pull even when repo is already there
// git_pullreset bool // means we will force a pull and reset old content
// coderoot string //the location of coderoot if its another one
pub fn cmd_run(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'run'
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
		flag: .string
		required: false
		name: 'circle'
		abbrev: 'c'
		description: 'circle id or circle name.'
	})
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
		description: 'name for the session (optional).'
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
		flag: .bool
		required: false
		name: 'editor'
		abbrev: 'code'
		description: 'Open visual studio code for where we found the 3script.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'sourcetree'
		abbrev: 'st'
		description: 'Open visual studio code for where we found the 3script.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'run'
		abbrev: 'r'
		description: 'Run the actions.'
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


	cmdroot.add_command(cmd_run)
}

fn cmd_3script_execute(cmd Command) ! {

	mut circle := cmd.flags.get_string('circle') or { 'test' }

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
	interactive := ! cmd.flags.get_bool('script') or { false }

	run := cmd.flags.get_bool('run') or { false }
	editor := cmd.flags.get_bool('editor') or { false }
	sourcetree := cmd.flags.get_bool('sourcetree') or { false }

	if url.len>0{
		path = gittools.code_get(
			coderoot: coderoot
			pull: pull
			reset: reset
			url: url
		)!
	}

	mut session:=play.session_new(
				session_name:sessionname, 
				context_name:contextname, 
				coderoot:coderoot
				interactive:interactive
				)!


	// println(h)
	if editor || sourcetree {
		mut gs := gittools.get(coderoot: coderoot) or {
			return error("Could not find gittools on '${coderoot}'\n${err}")
		}
		mut cmdname:="edit"
		if sourcetree{
			 cmdname="sourcetree"
		}
		gs.do(
			cmd: cmdname
			script: !interactive
			url: cmd.flags.get_string('url') or { '' }
		)!		

	}

	if cmd.flags.get_bool('run') or { false } {
		session.run()!
	}
}
