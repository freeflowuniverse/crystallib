module telegram

import freeflowuniverse.baobab.client
import freeflowuniverse.crystallib.redisclient
import vgram

// client for telegram bot
struct TelegramClient {
	bot vgram.Bot
	baobab  client.Client // Baobab client
}

// factory for telegram client initializes baobab client and redis queues
pub fn new_client() !TelegramClient {
	baobab := client.new()!
	return TelegramClient {
		baobab: baobab
	}
}

// listens for incoming messages, relays to flow
pub fn (mut client TelegramClient) run () {
	mut last_offset := 0 // used for tracking messages
	for {
		updates := client.bot.get_updates(offset: p.last_offset, limit: 100)
		for update in updates {
			// make sure message is new
			if last_offset < update.update_id { 
				if update.message.text == '/start' {
					// todo: do something for new chat
				}
				last_offset = update.update_id
				p.handle_update(update) or { continue }
			}
		}
	}
}

// forwards update to telegramui for handling
// todo: implement separate handlers for separate message types
fn (mut client TelegramClient) handle_update (update vgram.Update) {

// [params]
// pub struct JobNewArgs {
// pub mut:
// 	twinid       u32
// 	action       string
// 	args         Params
// 	actionsource string
// }

	job_args := JobNewArgs {
		action: 'ui.telegram.forward'
	}
	// creates job in jobs db and pushes to processor's incoming queue
	client.baobab.job_new_schedule()!
	
	user_id := update.message.from.id.str()
	text := update.message.text
	

}



	// // Infinite loop to deal with incoming and outgoing messages
	// for {
	// 	select {
	// 		output := <- ui.to_user {
	// 			ui.send(output.message, output.user_id)
	// 			ui.waiting_qs[output.user_id] = output.response_channel
	// 		}
	// 		else {
	// 			updates := ui.bot.get_updates(timeout: 0, allowed_updates: json.encode(["message"]), offset: last_offset, limit: 100)
	// 			for update in updates {
	// 				if last_offset < update.update_id {
	// 					last_offset = update.update_id
	// 					ui.handle_update(update) // ? Should this line be in the if statement?
	// 				}
	// 			}
	// 		}
	// 	}
	// }
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
		_ := ui.bot.send_message(
		chat_id: user_id,
		text: msg,
		parse_mode:'MarkdownV2'
	)
} 