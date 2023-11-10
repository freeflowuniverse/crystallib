module telegram

import dariotarantini.vgram
// import freeflowuniverse.crystallib.baobab.client
import freeflowuniverse.crystallib.data.paramsparser

pub struct UITelegram {
pub mut:
	// baobab  client.Client
	user_id string
}

pub fn new(user_id string) UITelegram {
	return UITelegram{
		// baobab: client.new()!
		user_id: user_id
	}
}

fn (ui UITelegram) send_question(msg string) !string {
	mut j_params := paramsparser.Params{}
	j_params.set('question', msg)

	// job := ui.baobab.job_new(
	// 	// todo twinid
	// 	action: 'ui.telegramclient.send_question'
	// 	params: j_params
	// 	// todo actionsource
	// )

	// response := ui.baobab.job_schedule_wait(job, 0)!

	// return response.result.get('answer')
}

fn (ui UITelegram) send_exit_message(msg string) ! {
	mut j_params := paramsparser.Params{}
	j_params.set('message', msg)

	job := ui.baobab.job_new(
		// todo twinid
		action: 'ui.telegramclient.exit_message'
		params: j_params
		// todo actionsource
	)

	response := ui.baobab.job_schedule(job)!
}

/*
needs to schedule new jobs and wait
*/
