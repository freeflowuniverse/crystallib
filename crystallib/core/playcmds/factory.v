module playcmds

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.ui.console

pub fn run(mut session base.Session) ! {
	session.process()!

	session.plbook.filtersort(priorities: session.playbook_priorities)!

	play_core(mut session)!
	play_ssh(mut session)!
	play_git(mut session)!
	play_mdbook(mut session)!
	play_zola(mut session)!

	session.plbook.empty_check()!

	console.print_item('All actions concluded succesfully.')
}
