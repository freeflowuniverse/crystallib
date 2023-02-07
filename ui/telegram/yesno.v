module telegram

import freeflowuniverse.crystallib.ui.uimodel {YesNoArgs}

pub fn (mut ui UITelegram) ask_yesno (args YesNoArgs) !string {
	q_args := QuestionArgs{
		question: args.question
		description: args.description
		warning: args.warning
		clear: args.clear
		user_id: args.user_id
	}
	return ui.ask_question(q_args) or {return error("Failed to ask question: $err")}
}