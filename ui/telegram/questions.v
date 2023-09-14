module telegram

import os
import freeflowuniverse.crystallib.ui.uimodel { DropDownArgs, QuestionArgs, YesNoArgs }
import freeflowuniverse.crystallib.timetools

// args:
// - description string
// - question string
// - warning: string (if it goes wrong, which message to use)
// - clear bool = true
// - regex: to check what result need to be part of
// - minlen: min nr of chars
//

// ! struct Output {
// 	message string
// 	response_channel chan string
// }

pub fn (mut ui UITelegram) ask_dropdown(args DropDownArgs) !string {
	mut description := '${args.description} \n\nChoices: \n'
	mut count := 1
	for item in args.items {
		description += '${count} - ${item}\n'
		count += 1
	}

	question := 'Please send your choice by entering a number from 1 to ${count}:'

	q_args := QuestionArgs{
		question: question
		description: description
		warning: args.warning
		clear: args.clear
		user_id: args.user_id
	}
	return ui.ask_question(q_args) or { return error('Failed to ask dropdown: ${err}') }
}

pub fn (mut ui UITelegram) ask_yesno(args YesNoArgs) !string {
	q_args := QuestionArgs{
		question: args.question
		description: args.description
		warning: args.warning
		clear: args.clear
		user_id: args.user_id
	}
	return ui.ask_question(q_args) or { return error('Failed to ask yesno: ${err}') }
}

pub fn (mut ui UITelegram) ask_question(args QuestionArgs) !string {
	mut message := ''

	mut warning := args.warning

	for {
		if args.description.len > 0 {
			message += '${make_safe(args.description)}\n'
		}
		if args.warning.len > 0 {
			message += '__${make_safe(args.warning)}__\n'
		}
		mut question := 'Please provide an answer:'
		if args.question != '' {
			question = args.question
		}
		message += '*bold \\*${make_safe(question)}*\n'

		warning = args.warning

		answer := ui.send_question(message)!

		if args.validation(answer) {
			return answer
		} else {
			warning += '\n ${err}'
		}
	}
}

pub fn (mut ui TelegramBot) ask_date(args QuestionArgs) !map[string]int {
	mut warning := args.warning
	for {
		date_string := ui.ask_question(args)
		args.warning = warning
		if date := timetools.parse_date(date_string) {
			return date
		}
		args.warning = warning +
			"\n Failed to parse date, please input a date of the format: '28 feb'"
	}
}

pub fn (mut ui TelegramBot) ask_time(args QuestionArgs) !map[string]int {
	mut warning := args.warning
	for {
		time_string := ui.ask_question(args)
		args.warning = warning
		if time := timetools.parse_time(time_string) {
			return time
		}
		args.warning = warning +
			"\n Failed to parse time, please input a time of the format: 'HH:MM'"
	}
}

fn make_safe(text string) string {
	mut new_text := ''
	for character in text {
		new_text += '\\${character.ascii_str()}'
	}
	return new_text
}
