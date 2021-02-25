module publishermod

import os

// make sure that the names are always normalized so its easy to find them back
pub fn name_fix(name string) string {
	mut pagename := name_fix_keepext(name)
	if pagename.ends_with('.md') {
		pagename = pagename[0..pagename.len - 3]
	}
	return pagename
}

pub fn name_fix_no_underscore(name string) string {
	mut pagename := name_fix_keepext(name)
	return pagename.replace('_', '')
}

pub fn name_fix_keepext(name_ string) string {
	mut name := name_.to_lower()
	if '#' in name {
		name = name.split('#')[0]
	}
	
	name = name.replace(' ', '_')
	name = name.replace('-', '_')
	name = name.replace(';', ':')
	name = name.replace('::', ':')
	name = name.trim(' .:')

	// need to replace . to _ but not the last one (because is ext) 
	extension := os.file_ext(name).trim('.')
	if extension != "" {
		name = name[..(name.len-extension.len-1)]
		name = name.replace('.', '_')
		name += ".$extension"
	}

	name = name.replace('__', '_')
	name = name.replace('__', '_') // needs to be 2x because can be 3 to 2 to 1	

	return name
}

// return (sitename,pagename)
// works for files & pages
pub fn name_split(name string) ?(string, string) {
	mut objname := name.trim(' ')
	objname = objname.trim_left('.')

	if "__" in name {
		parts := name.split("__")
		if parts.len != 2{
			return error('filename not well formatted. Needs to have 2 parts around "__". Now ${name}.')
		}
		objname = '${parts[0].trim(" ")}:${parts[1].trim(" ")}'
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
	if '/' in objname {
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
