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

pub fn (mut ui UITelegram) run() {
}

fn (mut ui UITelegram) handle_update(update vgram.Update) {
	user_id := update.message.from.id.str()
	text := update.message.text
	if user_id in ui.waiting_qs.keys() && text[0].ascii_str() != '/' {
		ui.waiting_qs[user_id].response_channel <- update.message.text
	} else {
		match text.trim_string_left('/').split(' ')[0] {
			'register' {}
			'order' {}
		}
	}
}
