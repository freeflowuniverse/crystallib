module template

// import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.ui.uimodel { DropDownArgs }

// return the dropdown as an int
// 	description string
// 	items       []string
// 	warning     string
// 	clear       bool = true
pub fn (mut c UIExample) ask_dropdown(args DropDownArgs) !string {
	return ''
}

// result can be multiple, also can select all
// 	description string
// 	items       []string
// 	warning     string
// 	clear       bool = true
pub fn (mut c UIExample) ask_dropdown_multiple(args DropDownArgs) ![]string {
	return []string{}
}

// will return the string as given as response
// 	description string
// 	items       []string
// 	warning     string
// 	clear       bool = true
pub fn (mut c UIExample) ask_dropdown_int(args DropDownArgs) !int {
	return 1
}
