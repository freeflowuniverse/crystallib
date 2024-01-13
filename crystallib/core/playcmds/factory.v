module playcmds

import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.ui.console

pub fn run(mut session play.Session) ! {
	session.process()!

	session.plbook.filtersort(priorities: session.playbook_priorities)!

	play_core(mut session)!
	play_ssh(mut session)!
	play_git(mut session)!
	play_mdbook(mut session)!

	session.plbook.empty_check()!

	console.print_item('All actions concluded succesfully.')
}
