module farmingsimulator

import freeflowuniverse.crystallib.core.playbook { Action }
import freeflowuniverse.crystallib.ui.console
//import json


pub fn playmacro( action Action) !string {

	// sheet_name := action.params.get('sheetname') or {
	// 	return error("can't find sheetname from sheet.chart macro.")
	// }
	// mut sh := sheet_get(sheet_name)!

	//console.print_debug(sh)

	supported_actions := ['node_wiki','regionalinternet_wiki']

	if !  supported_actions.contains(action.name) {
		return ""
	}

	mut p := action.params

	simulator_name:= action.params.get_default('simulator',"default")!

	mut sim:= simulator_get(simulator_name) or {return error("can't find simulator with name ${simulator_name}")}

	if action.name == "node_wiki" {
		console.print_green('playmacro node_wiki')
		name := p.get('name') or {return error("name needs to be specified for wiki_node macro")}
		return sim.node_template_wiki(name)!
	}

	if action.name == "regionalinternet_wiki" {
		console.print_green('playmacro regionalinternet_wiki')
		name := p.get('name') or {return error("name needs to be specified for regionalinternet_wiki macro")}
		return sim.regional_internet_wiki(name)!
	}

	return ''
}
