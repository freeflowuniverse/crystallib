module doctree

import freeflowuniverse.crystallib.core.texttools

// parse name of a page
// format is $collection:$name or $name
fn name_parse(name string) !(string, string) {
	if name.contains(':') {
		splitted := name.split(':')
		if splitted.len != 2 {
			return error("format is collection:name or just 'name'")
		}
		collection := texttools.name_fix(splitted[0])
		name_ := texttools.name_fix(splitted[1])
		return collection, name_
	} else {
		name_ := texttools.name_fix(name)
		return '', name_
	}
	return '', ''
}
