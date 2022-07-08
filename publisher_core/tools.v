module publisher_core

import freeflowuniverse.crystallib.texttools
import os

// return (sitename,pagename)
// works for files & pages
// sitename will be empty string if not specified with site:... or site__...
pub fn name_split(name string) ?(string, string) {
	mut objname := name.trim(' ')
	objname = objname.trim_left('.')

	if name.contains('__') {
		parts := name.split('__')
		if parts.len != 2 {
			return error('filename not well formatted. Needs to have 2 parts around "__". Now ${name}.')
		}
		objname = '${parts[0].trim(' ')}:${parts[1].trim(' ')}'
	}

	// to deal with things like "img/tf_world.jpg ':size=300x160'"
	splitted0 := objname.split(' ')
	if splitted0.len > 0 {
		objname = splitted0[0]
	}
	objname = texttools.name_fix(objname)
	mut sitename := ''
	splitted := objname.split(':')
	if splitted.len == 1 {
		objname = splitted[0]
	} else if splitted.len == 2 {
		sitename = splitted[0]
		objname = splitted[1]
	} else {
		return error("name needs to be in format 'sitename:filename' or 'filename', now '$objname'")
	}
	objname = objname.trim_left('.')
	if objname.contains('/') {
		objname = os.base(objname)
		if objname.trim(' ') == '' {
			return error('objname empty for os.base')
		}
	}
	// make sure we don't have the e.g. img/ in
	if objname.trim('/ ') == '' {
		return error('objname empty: $name')
	}
	if objname.ends_with('/') {
		return error("objname cannot end with /: now '$name'")
	}
	if objname.trim(' ') == '' {
		return error('objname empty: $name')
	}

	// eprintln(" >> namesplit: '$sitename' '$objname'")

	return sitename, objname
}
