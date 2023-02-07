module telegram

import dariotarantini.vgram

import json
// TODO
// need to create something here that:
// gets updates
// creates flows
// passes text into flow channels
// receives text from to_user channel
// sends messages to users

pub fn (mut ui UITelegram) run () {
	// Ensures that we dont respond to any old messages	
	mut last_offset := 1
	mut updates := bot.bot.get_updates(timeout: 0, allowed_updates: json.encode(["message"]), offset: last_offset, limit: 100)
	for update in updates {
		if last_offset < update.update_id {
			last_offset = update.update_id
		}
	}
	// Infinite loop to deal with incoming and outgoing messages
	for {
		select {
			output := <- ui.to_user {
				ui.send(output.message, output.user_id)
				ui.waiting_qs[output.user_id] = output.response_channel
			}
			else {
				updates := ui.bot.get_updates(timeout: 0, allowed_updates: json.encode(["message"]), offset: last_offset, limit: 100)
				for update in updates {
					if last_offset < update.update_id {
						last_offset = update.update_id
						ui.handle_update(update) // ? Should this line be in the if statement?
					}
				}
			}
		}
	}
}

fn (mut ui UITelegram) handle_update (update vgram.Update) {
	user_id := update.message.from.id.str()
	text := update.message.text
	if user_id in ui.waiting_qs.keys() && text[0].ascii_str() != '/'{
		ui.waiting_qs[user_id].response_channel <- update.message.text
	} else {
		match text.trim_string_left('/').split(' ')[0] {
			'register' {}
			'order' {}
		}
	}
}

fn (ui UITelegram) send (msg string, user_id string) {

	job := ui.baobab.job_new(
		action: 'ui.telegramclient.send_message'
		params: Params {
			key: 'user_id'
			value: ui.user_id
		}
	)

	response := job.wait()
}