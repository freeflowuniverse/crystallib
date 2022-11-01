module actionrunner

import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.params { Params }
import time

// find all actions & process, this works inclusive
fn actions_process(mut parser actionparser.ActionsParser, actions_done map[string]string) ?map[string]string {
	// $if debug {
	// 	println("+++++")
	// 	println(actions)
	// 	println("-----")
	// }

	gitrunner := new_gitrunner()
	go gitrunner.run()	
	time.sleep(500 * time.millisecond)

	// booksrunner := new_booksrunner()
	// go booksrunner.run()
	// time.sleep(500 * time.millisecond)

	for mut action in parser.actions {
		
		$if debug {
			println(' --------ACTION:\n$action\n--------')
		}
		if action.name.starts_with('git.') {
			msg := ActionMessage {
				name: action.name
				params: action.params
			}
			gitrunner.channel <- msg
			for {
				res := <- gitrunner.channel
				if res.name == msg.name && res.params == msg.params && res.complete {
					break
				}
			}
		}
		// else if action.name.starts_with('books.') {
		// 	msg := ActionMessage {
		// 		name: action.name
		// 		params: action.params
		// 	}
		// 	booksrunner.channel <- msg
		// 	for {
		// 		res := <- gitrunner.channel
		// 		if res.name == msg.name && res.params == msg.params && res.complete {
		// 			break
		// 		}
		// 	}
		// }
	}
	return actions_done
}
