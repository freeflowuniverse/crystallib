module playmacros

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.threefold.grid4.simulator
import freeflowuniverse.crystallib.biz.spreadsheet

pub fn play(mut plbook playbook.PlayBook) ! {
	console.print_green('play macros')
	simulator.play(mut plbook)!
}

pub fn playmacro(action playbook.Action) !string {
	//println(" ----- ${action.actor}")
	if action.actor == 'sheet' {
		return spreadsheet.playmacro(action)!
	}
	return ''
}
