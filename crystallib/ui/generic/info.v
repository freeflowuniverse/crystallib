module generic

import freeflowuniverse.crystallib.ui.console { UIConsole }
// import freeflowuniverse.crystallib.ui.telegram { UITelegram }
import freeflowuniverse.crystallib.ui.uimodel

// send info to the main pannel .
// (not every UI has all capability e.g. html)
// 
// ```
// args:
// 	content 	string //in specified format
// 	clear       bool //means screen is reset for content above
// 	lf_before int 	 //line feed before content
// 	lf_after int 
// 	cat InfoCat
//  components []ComponentCat
// enum InfoCat {
// 	txt
// 	html
// 	markdown
// }
// MORE THAN ONE COMPONENT CAN BE ADDED TO INFO
// enum ComponentCat {
// 	bootstrap
// 	htmx
// 	bulma
// }
// ```
// supports images, and other html elements 
// suggest to support htmx and limited js (how can we limit this)
pub fn (mut c UserInterface) info(args uimodel.InfoArgs) ! {
	// match mut c.channel {
	// 	UIConsole { return c.channel.info(args)! }
	// 	else { panic("can't find channel") }
	// }
}
