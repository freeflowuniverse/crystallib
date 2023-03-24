module markdowndocs

import freeflowuniverse.crystallib.params

pub struct MacroObj {
pub mut:
	cmd    string
	params params.Params
}

// fix cmd to remain lower case and dots only
pub fn cmd_fix(name string) !string {
	mut item := name.to_lower()
	item = item.trim(' ._')
	item = item.replace('!', '')
	for x in ':;[]{}' {
		if item.contains(x.str()) {
			return error('cannot have \'${x.str()}\' in cmd: ${item}')
		}
	}
	item = item.replace('-', '.')
	item = item.replace('__', '_')
	item = item.replace('__', '_') // needs to be 2x because can be 3 to 2 to 1
	return item
}

pub fn macro_parse(line_ string) !MacroObj {
	mut line := line_
	mut r := MacroObj{}

	line = line.trim(' !\n\r')

	mut splitted := line.split('\n').filter(it != '')
	if splitted.len < 1 {
		return error('cannot parse macro, need to be at least cmd, now "${line}"')
	}
	if splitted.len == 1 {
		splitted = splitted[0].split(' ')
	}
	r.cmd = cmd_fix(splitted[0])!
	line = line.all_after(splitted[0])
	p := params.parse(line)!
	r.params = p
	return r
}
