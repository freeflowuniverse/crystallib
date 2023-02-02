module ui
import freeflowuniverse.crystallib.ui.console {UIConsole}

//need to do this for each type of UI channel e.g. console, telegram, ...
type UIChannel = UIConsole

pub struct UserInterface{
pub mut:
	channel UIChannel
}

enum ChannelType{
	console
}

pub fn new(channeltype ChannelType)UserInterface{
	//TODO: implement telegram
	if channeltype == .console{
		mut channel:=UIConsole{}
		return UserInterface{channel:channel}
	}
	return error("Channel type not understood, only console supported now.")
}