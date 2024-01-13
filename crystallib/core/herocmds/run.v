module herocmds

import cli { Command, Flag }


// path string //if location on filessytem, if exists, this has prio on git_url
// git_url   string // location of where the hero scripts are
// git_pull     bool // means when getting new repo will pull even when repo is already there
// git_pullreset bool // means we will force a pull and reset old content
// coderoot string //the location of coderoot if its another one
pub fn cmd_run(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'run'
		description: '
## Powerfull command to run 3script

3script has numerous ways to execute actions using your hero tool.

example:

hero run -u https://git.ourworld.tf/threefold_coop/info_asimov/src/branch/main/script3 -r

The -r will run it, can also do -e or -st to see sourcetree


		'
		required_args: 0
		usage: ''
		execute: cmd_3script_execute
	}
	cmd_run_add_flags(mut cmd_run)

	cmdroot.add_command(cmd_run)
}

fn cmd_3script_execute(cmd Command) ! {
	mut session,path := session_run_edit_sourcecode(cmd)!
	println("sdsdsdddd")
}
