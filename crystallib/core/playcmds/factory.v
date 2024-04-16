module playcmds

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.playbook

pub fn run(mut plbook playbook.PlayBook) ! {
	play_core(mut plbook)!
	play_ssh(mut plbook)!
	play_git(mut plbook)!
	play_mdbook(mut plbook)!
	play_zola(mut plbook)!

	plbook.empty_check()!

	console.print_item('All actions concluded succesfully.')
}
