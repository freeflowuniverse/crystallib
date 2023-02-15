module ui

import freeflowuniverse.crystallib.ui.console {UIConsole}
import freeflowuniverse.crystallib.ui.telegram {UITelegram}
import freeflowuniverse.crystallib.ui.uimodel {QuestionArgs}

pub fn (mut c UserInterface) ask_date(args QuestionArgs) string {
	return match mut c.channel {
		// UIConsole { return c.ask_date(args) }
		UITelegram { return c.ask_date(args)}
		else{ return error("can't find channel")}
	}	
}

pub fn (mut c UserInterface) ask_time(args QuestionArgs) string {
	return match mut c.channel {
		// UIConsole { return c.ask_time(args) }
		UITelegram { return c.ask_time(args)}
		else{ return error("can't find channel")}
	}	
}