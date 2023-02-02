module console

import freeflowuniverse.crystallib.texttools
import os

[params]
pub struct DropDownArgs {
pub mut:
	all         bool // means user can choose all of them
	description string
	items       []string
	warning     string
	reset       bool = true
}

pub fn ask_dropdown_int(args DropDownArgs) int {
	if args.reset {
		clear() // clears the screen
	}
	if args.description.len > 0 {
		println(style(args.description, 'bold'))
	}
	if args.warning.len > 0 {
		println(color_fg(args.warning, 'red'))
		println('\n')
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
	println('')
	print(' - Make your choice:  ')
	choice := os.get_raw_line().trim(' \n')
	if choice.trim(' ') == '*' {
		// means we return all
		return 999999
	}
	if !texttools.is_int(choice) {
		return ask_dropdown_int(
			reset: true
			description: args.description
			all: args.all
			items: args.items
			warning: 'Choice needs to be a number (0...99).'
		)
	}
	choice_int := choice.int()
	if choice_int < 1 || choice_int > nr {
		return ask_dropdown_int(
			reset: true
			description: args.description
			all: args.all
			items: args.items
			warning: 'Choice needs to be a number larger than 0 and smaller than ${nr + 1}'
		)
	}
	return choice_int
}

// means we can return all
pub fn ask_dropdown_all(args DropDownArgs) []string {
	res := ask_dropdown_int(
		reset: args.reset
		description: args.description
		all: args.all
		items: args.items
		warning: ''
	)
	if res == 999999 {
		return args.items
	} else {
		return [args.items[res - 1]]
	}
}

// means we can return all
pub fn ask_dropdown(args DropDownArgs) string {
	res := ask_dropdown_int(
		reset: args.reset
		description: args.description
		all: args.all
		items: args.items
		warning: ''
	)
	return args.items[res - 1]
}
