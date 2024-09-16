module farmingsimulator

import freeflowuniverse.crystallib.biz.spreadsheet
// import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.threefold.grid4.cloudslices

@[heap]
pub struct Simulator {
pub mut:
	name               string
	sheet              &spreadsheet.Sheet
	args               SimulatorArgs
	params             Params
	nrmonths           int = 6 * 12
	regional_internets map[string]&RegionalInternet
	node_templates     map[string]&NodeTemplate
	components         map[string]&Component
	// params             Params
}

pub fn (mut s Simulator) regionalinternet_get(name_ string) !&RegionalInternet {
	name := name_.to_lower()
	return s.regional_internets[name] or {
		return error('Cannot find regional internet with name: ${name}')
	}
}

pub fn (mut s Simulator) nodetemplate_get(name_ string) !&NodeTemplate {
	name := name_.to_lower()
	return s.node_templates[name] or {
		return error('Cannot find note template with name: ${name}')
	}
}
