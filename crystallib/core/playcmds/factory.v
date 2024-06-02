module playcmds

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.virt.hetzner
import freeflowuniverse.crystallib.clients.b2

pub fn run(mut plbook playbook.PlayBook) ! {
	play_core(mut plbook)!
	play_ssh(mut plbook)!
	play_git(mut plbook)!
	play_mdbook(mut plbook)!
	play_zola(mut plbook)!
	hetzner.heroplay(mut plbook)!
	b2.heroplay(mut plbook)!

	// plbook.empty_check()!

	console.print_header('Actions concluded succesfully.')
}
