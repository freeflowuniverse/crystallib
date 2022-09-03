module publisher

import texttools

// if return true, means macro found and was ok
// format !!!$macroname $arg1 $arg2
// arg's can be one or more, can also be $name:$val then keyvalue which will become params
// the args always need to come first
fn macro_process(mut state LineProcessorState, line string) bool {
	fns_map := {
		'vimeo':       vimeo
		'iframe':      iframe
		'youtube':     youtube
		'def':         macro_def
		'def_list':    macro_def_list
		'alias':       macro_alias
		'tokens':      macro_tokens
		'time':        macro_time
		'code':        macro_code
		'tfpriceinfo': macro_tfpriceinfo
		'pdf':         macro_pdf
	}

	if !line.starts_with('!!!') {
		return false
	}
	if line.starts_with('!!!include') {
		return false
	}

	mut macro := texttools.macro_parse(line) or {
		state.error(err.msg())
		return true
	}
	if macro.cmd in fns_map {
		amethod := fns_map[macro.cmd]
		// println (" - macro: $macro.cmd $state.page.name")
		amethod(mut state, mut macro) or {
			state.error(err.msg())
			return true
		}
	} else {
		state.error('cannot find macro:$macro.cmd in line:${line}.')
	}
	return true
}
