module telegram

import freeflowuniverse.crystallib.ui.uimodel {DropDownArgs}

pub fn (mut ui UITelegram) ask_dropdown (args DropDownArgs) !string {

	mut description := '$args.description \n\nChoices: \n'
	mut count := 1
	for item in args.items {
		description += '$count - $item\n'
		count += 1
	}

	question := 'Please send your choice by entering a number from 1 to $count:'

	q_args := QuestionArgs{
		question: question
		description: description
		warning: args.warning
		clear: args.clear
		user_id: args.user_id
	}
	return ui.ask_question(q_args) or {return error("Failed to ask question: $err")}
}