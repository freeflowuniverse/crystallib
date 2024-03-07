module main

import os
import cli { Command }
import freeflowuniverse.crystallib.core.herocmds
import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.osal

fn do() ! {
	mut cmd := Command{
		name: 'hero'
		description: 'Your HERO toolset.'
		version: '1.0.12'
		disable_man: true
	}

	mut toinstall:=false
	if !osal.cmd_exists('mc') || !osal.cmd_exists('redis-cli') {
		toinstall=true
	}
	if osal.is_osx(){
		if !osal.cmd_exists('brew') {
			console.clear()
			mut myui := ui.new()!
			toinstall = myui.ask_yesno(
				question: 'we didn\'t find brew installed is it ok to install for you?'
				default: true
			)!
			if toinstall{
				base.install()!
			}			
			console.clear()
			console.print_stderr("Brew installed, please follow instructions and do hero ... again.")
			exit(0)

		}	
	}

	if toinstall{
		base.install()!
	}

	play.init_default()!

	herocmds.cmd_bootstrap(mut cmd)
	herocmds.cmd_run(mut cmd)
	herocmds.cmd_git(mut cmd)
	herocmds.cmd_init(mut cmd)
	herocmds.cmd_imagedownsize(mut cmd)
	// herocmds.cmd_biztools(mut cmd)
	// herocmds.cmd_gen(mut cmd)
	herocmds.cmd_sshagent(mut cmd)
	herocmds.cmd_installers(mut cmd)
	// herocmds.cmd_configure(mut cmd)
	// herocmds.cmd_postgres(mut cmd)
	herocmds.cmd_mdbook(mut cmd)
	herocmds.cmd_zola(mut cmd)
	


	cmd.setup()
	cmd.parse(os.args)

	
}

fn main() {
	do() or { panic(err) }
}
