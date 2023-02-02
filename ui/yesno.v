module ui

import freeflowuniverse.crystallib.ui.console {UIConsole}
import freeflowuniverse.crystallib.ui.uimodel {YesNoArgs}

// yes is true, no is false
// args:
// - description string
// - question string
// - warning string
// - clear bool = true 
//
pub fn (mut c UserInterface) ask_yesno(args YesNoArgs) !bool {
	return match mut c.channel {
		UIConsole { return c.ask_yesno(args) }
		else{ return error("can't find channel")}
	}	
}
