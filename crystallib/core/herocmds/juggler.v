module herocmds

import freeflowuniverse.crystallib.develop.juggler
import freeflowuniverse.crystallib.develop.gittools
import cli { Command, Flag }
import freeflowuniverse.crystallib.ui.console
import os

// path string //if location on filessytem, if exists, this has prio on git_url
// git_url   string // location of where the hero scripts are
// git_pull     bool // means when getting new repo will pull even when repo is already there
// git_pullreset bool // means we will force a pull and reset old content
// coderoot string //the location of coderoot if its another one
pub fn cmd_juggler(mut cmdroot Command) {
	mut cmd_juggler := Command{
		name: 'juggler'
		usage: '
## Continuous Integration and Deployment for Hero 

example:

hero juggler -u https://git.ourworld.tf/tfgrid/info_tfgrid/src/branch/main/heroscript

If you do -gp it will pull newest book content from git and give error if there are local changes.
If you do -gr it will pull newest book content from git and overwrite local changes (careful).

		'
		description: 'configure ci/cd for repos'
		required_args: 0
		execute: cmd_juggler_execute
	}

	cmd_run_add_flags(mut cmd_juggler)

	cmd_juggler.add_flag(Flag{
		flag: .bool
		required: false
		name: 'open'
		abbrev: 'o'
		description: 'will open the juggler user interface.'
	})

	cmdroot.add_command(cmd_juggler)
}

fn cmd_juggler_execute(cmd Command) ! {
	mut url := cmd.flags.get_string('url') or { '' }
	mut path := cmd.flags.get_string('path') or { '' }
	mut dagu_url := cmd.flags.get_string('dagu') or { '' }

	mut repo_path := ''
	if path.len > 0 || url.len > 0 {
		mut j := juggler.configure(url: url)!
		open := cmd.flags.get_bool('open') or { false }
		if open {
			j.open()!
		}
		j.run(8200)!
	} else {
		juggler_help(cmd)
	}
}

fn juggler_help(cmd Command) {
	console.clear()
	console.print_header('Instructions for juggler:')
	console.print_lf(1)
	console.print_stdout(cmd.help_message())
	console.print_lf(5)
}

// returns the path of the fetched repo
fn juggler_code_get(cmd Command) !string {
	mut path := cmd.flags.get_string('path') or { '' }
	mut url := cmd.flags.get_string('url') or { '' }

	// mut sessionname := cmd.flags.get_string('sessionname') or { '' }
	// mut contextname := cmd.flags.get_string('contextname') or { '' }

	mut coderoot := cmd.flags.get_string('coderoot') or { '' }
	if 'CODEROOT' in os.environ() && coderoot == '' {
		coderoot = os.environ()['CODEROOT']
	}

	if coderoot.len > 0 {
		panic('coderoot >0 not supported yet, not imeplemented.')
	}

	reset := cmd.flags.get_bool('gitreset') or { false }
	pull := cmd.flags.get_bool('gitpull') or { false }
	// interactive := !cmd.flags.get_bool('script') or { false }

	mut gs := gittools.get()!
	if url.len > 0 {
		path = gs.code_get(
			pull: pull
			reset: reset
			url: url
			reload: true
		)!
	}

	return path
}

