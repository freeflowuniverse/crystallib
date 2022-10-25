// make sure that the names are always normalized so its easy to find them back
module texttools

import os

const ignore = '\\/[]()?!@#$%^&*<>:;{}|'

pub fn name_fix(name string) string {
	name2 := name_fix_keepext(name)
	return name2
}

// get name back keep extensions and underscores, but when end on .md then remove extension
pub fn name_fix_no_md(name string) string {
	pagename := name_fix_keepext(name)
	if pagename.ends_with('.md') {
		fixed_pagename := pagename[0..pagename.len - 3]
		return fixed_pagename
	}
	return pagename
}

pub fn name_fix_no_underscore(name string) string {
	mut pagename := name_fix_keepext(name)
	x := pagename.replace('_', '')

	return x
}

// remove underscores and extension
pub fn name_fix_no_underscore_no_ext(name_ string) string {
	return name_fix_keepext(name_).all_before_last('.').replace('_', '')
}

// remove underscores and extension
pub fn name_fix_no_ext(name_ string) string {
	return name_fix_keepext(name_).all_before_last('.').trim_right('_')
}




pub fn name_fix_keepext(name_ string) string {
	mut name := name_.to_lower()
	if name.contains('#') {
		old_name := name
		name = old_name.split('#')[0]
	}

	name = name.replace(' ', '_')
	name = name.replace('-', '_')
	name = name.replace(';', ':')
	name = name.replace('::', ':')
	name = name.trim(' .:')

	// need to replace . to _ but not the last one (because is ext)
	fext := os.file_ext(name)
	extension := fext.trim('.')
	if extension != '' {
		name = name[..(name.len - extension.len - 1)]
		name = name.replace('.', '_')
		name = name + '.$extension'
	}
	name = name.replace('__', '_')
	name = name.replace('__', '_') // needs to be 2x because can be 3 to 2 to 1

	for c in texttools.ignore {
		if name.contains(c.str()) {
			name = name.replace(c.str(), '')
		}
	}

	// to make sure that future garbage collection works
	name = name.clone()

	return name
}
