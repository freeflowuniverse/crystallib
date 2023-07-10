module texttools

pub struct MacroObj {
pub mut:
	cmd    string
	params Params
}

// fix cmd to remain lower case and dots only
pub fn cmd_fix(name string) ?string {
	mut item := name.to_lower()
	item = item.trim(' ._')
	item = item.replace('!', '')
	for x in ':;[]{}' {
		if item.contains(x.str()) {
			return error('cannot have \'$x.str()\' in cmd: $item')
		}
	}
	item = item.replace('-', '.')
	item = item.replace('__', '_')
	item = item.replace('__', '_') // needs to be 2x because can be 3 to 2 to 1
	return item
}

pub fn macro_parse(line_ string) ?MacroObj {
	mut line := line_
	mut r := MacroObj{}

	line = line.trim(' ')
	line = line.trim('!')
	line = line.trim(' ')

	splitted := line.split(' ')

	if splitted.len < 1 {
		return error('cannot parse macro, need to be at least cmd, now "$line"')
	}

	r.cmd = cmd_fix(splitted[0])?

	if splitted.len > 1 {
		line = splitted[1..].join(' ')
	}
	params := text_to_params(line)?
	r.params = params

	return r
}
