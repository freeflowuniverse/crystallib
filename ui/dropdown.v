module console

import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.console {style}
import os

[params]
pub struct DropDownArgs {
pub mut:
	description string
	items       []string
	warning     string
	clear       bool = true
}


//return the dropdown as an int
// 	description string
// 	items       []string
// 	warning     string
// 	clear       bool = true
pub fn (mut c UIChannel) ask_dropdown(args DropDownArgs) int {
}

// result can be multiple, aloso can select all
// 	description string
// 	items       []string
// 	warning     string
// 	clear       bool = true
pub fn (mut c UIChannel) ask_dropdown_multiple(args DropDownArgs) []string {

}

// will return the string as given as response
// 	description string
// 	items       []string
// 	warning     string
// 	clear       bool = true
pub fn (mut c UIChannel) ask_dropdown_string(args DropDownArgs) string {
	res := ask_dropdown_int(
		reset: args.reset
		description: args.description
		all: args.all
		items: args.items
		warning: ''
	)
	return args.items[res - 1]
}
