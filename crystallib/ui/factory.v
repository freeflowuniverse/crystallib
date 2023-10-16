module ui

import freeflowuniverse.crystallib.ui.generic { ChannelType, UserInterface }
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.data.paramsparser
// import freeflowuniverse.crystallib.ui.telegram

[params]
pub struct UserInterfaceArgs {
pub mut:
	channel ChannelType
	params  params.Params // to pass arguments to implementation
}

pub fn new(args UserInterfaceArgs) !UserInterface {
	mut ch := match args.channel {
		.console { console.new() }
		// .telegram { telegram.new() }
		else { panic("can't find channel") }
	}

	return UserInterface{
		channel: ch
	}
	// return error("Channel type not understood, only console supported now.") // input is necessarily valid
}
