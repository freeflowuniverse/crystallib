module console

import os

pub struct QuestionArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool = true
	regex       string
	minlen      int
}

// args:
// - description string
// - question string
// - warning: string (if it goes wrong, which message to use)
// - reset bool = true
// - regex: to check what result need to be part of
// - minlen: min nr of chars
//
pub fn (mut c UIConsole) ask_question(args QuestionArgs) string {
	mut question := args.question
	if args.clear {
		clear() // clears the screen
	}
	if args.description.len > 0 {
		println(style(args.description, 'bold'))
	}
	if args.warning.len > 0 {
		println(color_fg(args.warning, 'red'))
		println('\n')
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
		return ask_question(
			reset: args.reset
			description: args.description
			warning: 'Min lenght of answer is: ${args.minlen}'
			question: args.question
		)
	}
	return choice
}
