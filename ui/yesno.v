module console

import os

pub struct YesNoArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool = true
}

// yes is true, no is false
// args:
// - description string
// - question string
// - warning string
// - clear bool = true 
//
pub fn (mut c UIChannel) ask_yesno(args YesNoArgs) bool {
	//TODO: do the matching
}
