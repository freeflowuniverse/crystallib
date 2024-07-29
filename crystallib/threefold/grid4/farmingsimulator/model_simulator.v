module farmingsimulator

@[heap]
pub struct Simulator {
pub mut:
	name   	string
	sheet  	&spreadsheet.Sheet
	params 	SimulatorArgs
	nrmonths           int = 6 * 12
	regional_internets map[string]&RegionalInternet
	node_templates     map[string]&NodeTemplate
	components         map[string]&Component
	//params             Params
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
