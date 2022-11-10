module books

import freeflowuniverse.crystallib.texttools

// return sitename if any (otherwise empty string) and page or filename
// if is image will remove extension and last _ (before extension)
fn get_site_and_obj_name(txt_ string, ismage bool) !(string, string) {
	mut txt := txt_.trim_space().replace('\\', '/').replace('//', '/').all_after_last('/')
	mut a := ''
	mut b := texttools.name_fix_keepext(txt)
	if b.contains(':') {
		a = txt.all_before(':').replace('_', '')
		b = txt.all_after_first(':')
		if b.contains(':') {
			return error("can only have 1 : in txt:'$txt'")
		}
	}
	if ismage {
		b = b.all_before_last('.')
		b = b.trim_right('_')
	}
	if b.ends_with('.md') {
		b = b.all_before_last('.')
	}
	return a, b
}
