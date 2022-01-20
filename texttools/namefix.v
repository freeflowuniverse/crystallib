// make sure that the names are always normalized so its easy to find them back
module texttools

import os

pub fn name_fix(name string) string {
	pagename := name_fix_keepext(name)

	if pagename.ends_with('.md') {
		fixed_pagename := pagename[0..pagename.len - 3]
		return fixed_pagename
	}
	res := pagename.clone()
	return res
}

pub fn name_fix_no_filesep(name string) string {
	mut name1 := name.replace('/', '_')
	name1 = name1.replace('\\', '_')
	name1 = name1.replace('[', '')
	name1 = name1.replace(']', '')
	name1 = name1.replace('(', '')
	name1 = name1.replace(')', '')
	name1 = name1.replace('?', '')
	// name1 = name1.ascii_str()
	//is there no better way to do this???? 
	return name_fix(name1)
}

pub fn name_fix_no_underscore(name string) string {
	mut pagename := name_fix_keepext(name)
	x := pagename.replace('_', '')

	return x
}

pub fn name_fix_no_underscore_no_ext(name_ string) string {
	return name_fix_keepext(name_).all_before_last(".").trim_right("_")
}

pub fn name_fix_keepext(name_ string) string {
	mut name := name_.to_lower()
	if name.contains('#') {
		old_name := name
		name = old_name.split('#')[0]
	}

	name1 := name.replace(' ', '_')

	name2 := name1.replace('-', '_')

	name3 := name2.replace(';', ':')

	name4 := name3.replace('::', ':')

	name5 := name4.trim(' .:')

	name = name5.clone()

	// need to replace . to _ but not the last one (because is ext)
	fext := os.file_ext(name)
	extension := fext.trim('.')
	if extension != '' {
		name_x1 := name[..(name.len - extension.len - 1)]
		name_x2 := name_x1.replace('.', '_')
		name_x3 := name_x2 + '.$extension'
		name = name_x3.clone()
	}
	name6 := name.replace('__', '_')
	name7 := name6.replace('__', '_') // needs to be 2x because can be 3 to 2 to 1

	return name7
}
