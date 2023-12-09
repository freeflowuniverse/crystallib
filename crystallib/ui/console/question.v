module console

import os
import freeflowuniverse.crystallib.ui.uimodel { QuestionArgs }
// import freeflowuniverse.crystallib.ui.console { color_fg }

// args:
// - description string
// - question string
// - warning: string (if it goes wrong, which message to use)
// - reset bool = true
// - regex: to check what result need to be part of
// - minlen: min nr of chars
//
pub fn (mut c UIConsole) ask_question(args QuestionArgs) !string {
	mut question := args.question
	if args.clear {
		clear() // clears the screen
	}
	if args.description.len > 0 {
		cprintln(text:args.description)
	}
	if args.warning.len > 0 {
		cprintln(foreground:.red,text:args.warning+"\n")
	}
	if question == '' {
		question = 'Please provide answer: '
	}
	print('${question}: ')
	choice := os.get_raw_line().trim(' \n')
	if args.regex.len > 0 {
		panic('need to implement regex check')
	}
	if args.minlen > 0 && choice.len < args.minlen {
		return c.ask_question(
			reset: args.reset
			description: args.description
			warning: 'Min lenght of answer is: ${args.minlen}'
			question: args.question
		)
	}
	return choice
}
