module herocmds

import freeflowuniverse.crystallib.osal.gittools
// import freeflowuniverse.crystallib.baobab.hero
import cli { Command, Flag }
import os

// path string //if location on filessytem, if exists, this has prio on git_url
// git_url   string // location of where the hero scripts are
// git_pull     bool // means when getting new repo will pull even when repo is already there
// git_pullreset bool // means we will force a pull and reset old content
// coderoot string //the location of coderoot if its another one
pub fn cmd_3script_do(mut cmdroot Command) {
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
		name: 'url'
		abbrev: 'u'
		description: 'url where 3script can be found.'
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

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'run'
		abbrev: 'r'
		description: 'Run the runner.'
	})

	cmdroot.add_command(cmd_run)
}

fn cmd_3script_execute(cmd Command) ! {
	// coderoot := cmd.flags.get_string('coderoot') or { '' }
	// mut path := cmd.flags.get_string('path') or { '' }
	// mut circle := cmd.flags.get_string('circle') or { 'test' }
	// mut url := cmd.flags.get_string('url') or { '' }
	// if path == '' {
	// 	path = url
	// }

	// mut gs := gittools.get(coderoot: coderoot) or {
	// 	return error("Could not find gittools on '${coderoot}'\n${err}")
	// }

	// mut h := hero.new(
	// 	cid: circle
	// 	gitstructure: gs
	// 	url: path
	// )!

	// println(h)

	// if cmd.flags.get_bool('run') or { false } {
	// 	h.run()!
	// }
}
