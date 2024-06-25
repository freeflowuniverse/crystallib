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
<<<<<<< HEAD
	//println(" ----- ${action.actor}")
	if action.actor == "sheet"{
=======
	console.print_debug(' ----- ${action.actor}')
	if action.actor == 'sheet' {
>>>>>>> 1e48732e4f5b46e52fb1098550f18e9506b2a605
		return spreadsheet.playmacro(action)!
	}
	return ''
}
