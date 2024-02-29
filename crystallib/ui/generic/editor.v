module generic

import freeflowuniverse.crystallib.ui.console { UIConsole }
// import freeflowuniverse.crystallib.ui.telegram { UITelegram }
import freeflowuniverse.crystallib.ui.uimodel

// open editor which can be used to edit content
// (not every UI has all capability, in case of console open vscode if installed)
// ```
// args:
// 	 content 	string //in specified format
//   cat ...
// enum InfoCat {
// 	content 	string //in specified format
// 	cat EditorCat
// }
// ```
// returns the editted content, idea is that formatting is used in editor
pub fn (mut c UserInterface) edit(args uimodel.EditArgs) !string{
	// match mut c.channel {
	// 	UIConsole { return c.channel.editor(args)! }
	// 	else { panic("can't find channel") }
	// }
}
