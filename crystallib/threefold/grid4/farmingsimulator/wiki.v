
module farmingsimulator

import freeflowuniverse.crystallib.ui.console


pub fn (mut s Simulator) node_template_wiki(name_ string) !string {

	name := name_.to_lower()
	mut nodetemplate:= s.node_templates[name] or {
		return error('Cannot find node template with name: ${name}')
	}

	nodewiki := $tmpl("templates/node_template.md")
	return nodewiki

}


pub fn (mut s Simulator) regional_internet_wiki(name_ string) !string {

	name := name_.to_lower()
	mut ri:= s.regional_internets[name] or {
		return error('Cannot find note regional internet with name: ${name}')
	}

	wiki := $tmpl("templates/regionalinternet_template.md")
	return wiki

}


