module template

import freeflowuniverse.crystallib.ui.uimodel { YesNoArgs }

// yes is true, no is false
// args:
// - description string
// - question string
// - warning string
// - clear bool = true
//
pub fn (mut c UIExample) ask_yesno(args YesNoArgs) !bool {
	return true
}
