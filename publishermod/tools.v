module publishermod

import os

// make sure that the names are always normalized so its easy to find them back
[manualfree]
pub fn name_fix(name string) string {
	pagename := name_fix_keepext(name)
	defer {
		unsafe { pagename.free() }
	}
	if pagename.ends_with('.md') {
		fixed_pagename := pagename[0..pagename.len - 3]
		return fixed_pagename
	}
	res := pagename.clone()
	return res
}

[manualfree]
pub fn name_fix_no_underscore(name string) string {
	mut pagename := name_fix_keepext(name)
	x := pagename.replace('_', '')
	unsafe { pagename.free() }
	return x
}

[manualfree]
pub fn name_fix_keepext(name_ string) string {
	mut name := name_.to_lower()
	if name.contains('#') {
		old_name := name
		name = old_name.split('#')[0]
		unsafe { old_name.free() }
	}

	name1 := name.replace(' ', '_')
	unsafe { name.free() }

	name2 := name1.replace('-', '_')
	unsafe { name1.free() }

	name3 := name2.replace(';', ':')
	unsafe { name2.free() }

	name4 := name3.replace('::', ':')
	unsafe { name3.free() }

	name5 := name4.trim(' .:')
	unsafe { name4.free() }

	name = name5.clone()
	unsafe { name5.free() }

	// need to replace . to _ but not the last one (because is ext)
	fext := os.file_ext(name)
	extension := fext.trim('.')
	if extension != '' {
		name_x1 := name[..(name.len - extension.len - 1)]
		unsafe { name.free() }
		name_x2 := name_x1.replace('.', '_')
		name_x3 := name_x2 + '.$extension'
		name = name_x3.clone()
		unsafe { name_x3.free() }
		unsafe { name_x2.free() }
		unsafe { name_x1.free() }
	}
	unsafe { extension.free() }
	unsafe { fext.free() }

	name6 := name.replace('__', '_')
	unsafe { name.free() }
	name7 := name6.replace('__', '_') // needs to be 2x because can be 3 to 2 to 1
	unsafe { name6.free() }

	return name7
}

// return (sitename,pagename)
// works for files & pages
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
	objname = name_fix(objname)
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
