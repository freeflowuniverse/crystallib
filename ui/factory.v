module ui

import freeflowuniverse.crystallib.ui.console { UIConsole }
import freeflowuniverse.crystallib.ui.telegram { UITelegram }

// need to do this for each type of UI channel e.g. console, telegram, ...
type UIChannel = UIConsole | UITelegram // TODO TelegramBot

pub struct UserInterface {
pub mut:
	channel UIChannel
	user_id string
}

enum ChannelType {
	console
	telegram
}

pub fn new(channel_type string, user_id string) !UserInterface {
	mut channel := match channel_type {
		'console' { console.new() }
		'telegram' { telegram.new() }
	}
	return UserInterface{
		channel: channel
		user_id: user_id
	}
	// return error("Channel type not understood, only console supported now.") // input is necessarily valid
}
