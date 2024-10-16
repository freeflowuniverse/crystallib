module data

// processes def pointers, returns list of encountered errors
pub fn (mut page Page) process_def_pointers(tree_defs map[string]&Page) ! {
	mut errs := PageMultiError{}
	mut doc := page.doc()!
	for mut defitem in doc.defpointers() {
		defname := defitem.nameshort
		mut def_page := tree_defs[defname] or {
			errs.errs << PageError{
				path: page.path
				msg: 'def ${defname} not found in page: ${page.path.path}'
				cat: .def
			}
			continue
		}

		defitem.pagekey = def_page.key()
		defitem.pagename = def_page.alias
		defitem.process_link()!
	}

	doc.process()!
	page.changed = true

	if errs.errs.len > 0 {
		return errs
	}
}
