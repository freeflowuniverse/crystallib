module v
import freeflowuniverse.crystallib.ui.console {UIConsole}
import freeflowuniverse.crystallib.ui.telegram {UITelegram}

//need to do this for each type of UI channel e.g. console, telegram, ...
type UIChannel = UIConsole | UITelegram // TODO TelegramBot

pub struct UserInterface{
pub mut:
	channel UIChannel
}

enum ChannelType{
	console
	telegram
}

pub fn new(channeltype ChannelType)!UserInterface{
	mut channel := match channeltype {
		.console {console.new()}
		.telegram {telegram.new()}
	}
	return UserInterface{channel:channel}
	// return error("Channel type not understood, only console supported now.") // input is necessarily valid
}