module generic

import freeflowuniverse.crystallib.ui.console { UIConsole }
// import freeflowuniverse.crystallib.ui.telegram { UITelegram }
import freeflowuniverse.crystallib.ui.uimodel

// yes is true, no is false
// args:
// - description string
// - question string
// - warning string
// - clear bool = true
//
pub fn (mut c UserInterface) ask_yesno(args uimodel.YesNoArgs) bool {
	return match mut c.channel {
		UIConsole { c.channel.ask_yesno(args) }
		// UITelegram{ return c.ask_yesno(args) }
		else { panic("can't find channel") }
	}
}
