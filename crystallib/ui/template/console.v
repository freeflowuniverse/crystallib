module template

import freeflowuniverse.crystallib.ui.console

pub fn clear() {
	console.print_debug('\033[2J')
}
