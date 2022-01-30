module console
import os

pub struct QuestionArgs{
pub mut:
	description string
	question string
	warning string
	reset bool = true
	regex string
	minlen int
}


//args:
// - description string
// - question string
// - warning string
// - reset bool = true
//
pub fn ask_question( args QuestionArgs) string{
	mut question := args.question
	if args.reset{
		clear() //clears the screen
	}
	if args.description.len>0{
		println(style(args.description,"bold"))
	}	
	if args.warning.len>0{
		println(color_fg(args.warning,"red"))
		println("\n")
	}
	if question==""{
		question = "Please provide answer: "
	}
    print("$question: ")
	choice := os.get_raw_line().trim(" \n")
	if args.regex.len>0{
		panic("need to implement regex check")
	}
	if args.minlen>0 && choice.len<args.minlen{
		return ask_question( reset:args.reset,description:args.description,
			warning:"Min lenght of answer is: ${args.minlen}",question:args.question)
	}
	return choice
}
