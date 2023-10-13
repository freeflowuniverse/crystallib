module herocmds

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.baobab.hero
import cli { Command, Flag }
import os

// path string //if location on filessytem, if exists, this has prio on git_url
// git_url   string // location of where the hero scripts are
// git_pull     bool // means when getting new repo will pull even when repo is already there
// git_pullreset bool // means we will force a pull and reset old content
// coderoot string //the location of coderoot if its another one
pub fn cmd_3script_do(mut cmdroot Command) {
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

	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'coderoot'
		abbrev: 'cr'
		description: 'Set code root for gittools.'
	})

	cmdroot.add_command(cmd_run)
}

fn cmd_3script_execute(cmd Command) ! {
	coderoot := cmd.flags.get_string('coderoot') or { '' }
	mut path := cmd.flags.get_string('path') or { '' }

	mut gs := gittools.get(root: coderoot, create: true) or {
		return error("Could not find gittools on '${coderoot}'\n${err}")
	}

	hero.new(
		cid: 'acircle'
		gitstructure: gs
		url: path
	)!
}
