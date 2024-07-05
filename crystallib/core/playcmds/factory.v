module playcmds

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.virt.hetzner
import freeflowuniverse.crystallib.clients.b2
import freeflowuniverse.crystallib.threefold.grid4.simulator

pub fn run(mut plbook playbook.PlayBook) ! {
	play_core(mut plbook)!
	play_ssh(mut plbook)!
	play_git(mut plbook)!
	play_mdbook(mut plbook)!
	play_zola(mut plbook)!
	play_caddy(mut plbook)!
	play_luadns(mut plbook)!
	hetzner.heroplay(mut plbook)!
	b2.heroplay(mut plbook)!
	simulator.play(mut plbook)!

	// plbook.empty_check()!

	console.print_header('Actions concluded succesfully.')
}
