module doctree

import freeflowuniverse.crystallib.core.texttools

// parse name of a page
// format is $playbook:$name or $name
fn name_parse(name string) !(string, string) {
	if name.contains(':') {
		splitted := name.split(':')
		if splitted.len != 2 {
			return error("format is playbook:name or just 'name'")
		}
		playbook := texttools.name_fix(splitted[0])
		name_ := texttools.name_fix(splitted[1])
		return playbook, name_
	} else {
		name_ := texttools.name_fix(name)
		return '', name_
	}
	return '', ''
}
