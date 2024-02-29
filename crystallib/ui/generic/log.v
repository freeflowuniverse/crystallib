module generic

import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.ui.telegram { UITelegram }
import freeflowuniverse.crystallib.ui.uimodel

// log content to the log panel (not every UI has this capability)
// ```
// args:
// 	content 	string
// 	clear       bool //means screen is reset for content above
// 	lf_before int 	 //line feed before content
// 	lf_after int
//  cat LogCat
// defines colors as used in the representation layer
// enum LogCat {
// 	info
// 	log
// 	warning
// 	header
// 	debug
// 	error
// }
// ```
pub fn (mut c UserInterface) log(args uimodel.LogArgs) ! {
	// match mut c.channel {
	// 	UIConsole { return c.channel.log(args)! }
	// 	else { panic("can't find channel") }
	// }
}
