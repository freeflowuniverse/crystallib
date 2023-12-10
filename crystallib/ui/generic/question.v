module generic

import freeflowuniverse.crystallib.ui.console { UIConsole }
// import freeflowuniverse.crystallib.ui.telegram { UITelegram }
import freeflowuniverse.crystallib.ui.uimodel { QuestionArgs }

// args:
// - description string
// - question string
// - warning: string (if it goes wrong, which message to use)
// - reset bool = true
// - regex: to check what result need to be part of
// - minlen: min nr of chars
//
pub fn (mut c UserInterface) ask_question(args QuestionArgs) !string {
	match mut c.channel {
		UIConsole { return c.channel.ask_question(args)! }
		// UITelegram { return c.ask_question(args) }
		else { panic("can't find channel") }
	}
}
