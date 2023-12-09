module console

// import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.ui.console { color_fg }
import freeflowuniverse.crystallib.ui.uimodel { DropDownArgs }
import os

// return the dropdown as an int
// 	description string
// 	items       []string
// 	warning     string
// 	clear       bool = true
pub fn (mut c UIConsole) ask_dropdown(args DropDownArgs) !int {
	if args.clear {
		clear() // clears the screen
	}
	if args.description.len > 0 {
		cprintln(style:.bold,text:args.description)
	}
	if args.warning.len > 0 {
		cprintln(foreground:.red,text:args.warning+"\n")
	}
	println('\nChoices:\n')
	mut items2 := args.items.clone()
	items2.sort()
	mut nr := 0
	for item in items2 {
		nr += 1
		println(' - ${nr} : ${item}')
	}
	if args.all {
		println(' - all : *')
	}
	if args.default.len>0 {
		println(' - default : ${args.default.join(",")}')
	}	
	println('')
	print(' - Make your choice:  ')
	choice := os.get_raw_line().trim(' \n')
	if choice.trim_space() == '*' {
		// means we return all
		return 999999
	}
	if choice.trim_space() == "" && args.default.len>0{
		if args.default.len==1{
			return args.items.index(args.default[0])
		}else{
			return 999998
		}
		
	}
	// TODO: fix
	// if !texttools.is_int(choice) {
	// if false {
	// 	return c.ask_dropdown(
	// 		clear: true
	// 		description: args.description
	// 		all: args.all
	// 		items: args.items
	// 		warning: 'Choice needs to be a number (0...99).'
	// 	)
	// }
	choice_int := choice.int()
	if choice_int < 1 || choice_int > nr {
		return c.ask_dropdown(
			clear: true
			description: args.description
			all: args.all
			items: args.items
			default: args.default
			warning: 'Choice needs to be a number larger than 0 and smaller than ${nr + 1}'
		)
	}
	return choice_int
}

// result can be multiple, aloso can select all
// 	description string
// 	items       []string
// 	warning     string
// 	clear       bool = true
pub fn (mut c UIConsole) ask_dropdown_multiple(args DropDownArgs) ![]string {
	res := c.ask_dropdown(
		clear: args.clear
		description: args.description
		all: args.all
		items: args.items
		default: args.default
		warning: ''
	)!
	if res == 999999 {
		return args.items
	}else if res == 999998 {
		return args.default
	} else {
		return [args.items[res - 1]]
	}
}

// will return the string as given as response
// 	description string
// 	items       []string
// 	warning     string
// 	clear       bool = true
pub fn (mut c UIConsole) ask_dropdown_string(args DropDownArgs) !string {
	res := c.ask_dropdown(
		clear: args.clear
		description: args.description
		all: args.all
		items: args.items
		default: args.default
		warning: ''
	)!
	if res == 999998 {
		return args.default[0] or {panic("bug in default args for ask_dropdown_string.\n")}
	}
	return args.items[res - 1]
}
