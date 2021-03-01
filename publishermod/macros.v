module publishermod

import despiegk.crystallib.texttools

// if return true, means macro found and was ok
// format !!!$macroname $arg1 $arg2 
// arg's can be one or more, can also be $name:$val then keyvalue which will become params
// the args always need to come first
fn macro_process(mut state LineProcessorState, line string) bool {
	fns_map := map{
		'vimeo':   vimeo
		'iframe':  iframe
		'youtube': youtube
	}

	if !line.starts_with('!!!') {
		return false
	}
	if line.starts_with('!!!def') {
		return false
	}
	if line.starts_with('!!!include') {
		return false
	}

	mut macro := texttools.macro_parse(line) or {
		state.error(err)
		return true
	}
	if macro.cmd in fns_map {
		amethod := fns_map[macro.cmd]
		amethod(mut state, mut macro) or {
			state.error(err)
			return true
		}
	} else {
		state.error('cannot find macro:$macro.cmd in line:${line}.')
	}
	return true
}
