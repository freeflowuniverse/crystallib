// make sure that the names are always normalized so its easy to find them back
module texttools

import os

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

pub fn name_fix_snake_to_pascal(name string) string {
	x := name.replace('_', ' ')
	pascal := x.title().replace(' ', '')
	return pascal
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

	// need to replace . to _ but not the last one (because is ext)
	fext := os.file_ext(name)
	extension := fext.trim('.')
	if extension != '' {
		name = name[..(name.len - extension.len - 1)]
	}

	to_replace_ := '-;:. '
	mut to_replace := []u8{}
	for i in to_replace_ {
		to_replace << i
	}

	mut out := []u8{}
	mut prev := u8(0)
	for u in name {
		if u == 95 { // underscore
			if prev != 95 {
				// only when previous is not _
				out << u
			}
		} else if u > 47 && u < 58 { // see https://www.charset.org/utf-8
			out << u
		} else if u > 96 && u < 123 {
			out << u
		} else if u in to_replace {
			out << u8(95)
		} else {
			// means previous one should not be used
			continue
		}
		prev = u
	}
	name = out.bytestr()

	// name = name.trim(' _') //DONT DO final _ is ok to keep

	if extension.len > 0 {
		name += '.${extension}'
	}
	return name
}
