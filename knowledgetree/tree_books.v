module knowledgetree


//process the summary
fn (book MDBook) process_summary()! {

	// is case insensitive
	//? checks for both summary.md files and links
	mut summarypath := p.file_get('summary.md') or {
		p.link_get('summary.md') or { return error('cannot find summary path: ${err}') }
	}
	mut doc := markdowndocs.new(path: summarypath.path) or {
		panic('cannot book parse ${summarypath} ,${err}')
	}

	//TODO: now we need to walk over all parts of the summary and for each item check we find collection (collection exists)

	panic("too implement, there was code but i lost it")

}



//FIND METHODS ON TREE

pub struct BookNotFound {
	Error
pub:
	bookname string
	tree  &Tree
	msg      string
}

pub fn (tree Tree) booknames() []string {
	mut res := []string{}
	for _, book in tree.books {
		res << book.name
	}
	res.sort()
	return res
}

pub fn (err BookNotFound) msg() string {
	booknames := err.tree.booknames().join('\n- ')
	if err.msg.len > 0 {
		return err.msg
	}
	return "Cannot not find book:'${err.bookname}'.\nKnown books:\n${booknames}"
}

pub fn (tree Tree) book_get(name string) !&MDBook {
	if name.contains(':') {
		return BookNotFound{
			tree: &tree
			msg: 'bookname cannot have : inside'
			bookname: name
		}
	}
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower == '' {
		return BookNotFound{
			tree: &tree
			msg: 'book needs to be specified, now empty.'
		}
	}
	return tree.books[namelower] or {
		return BookNotFound{
			tree: &tree
			bookname: name
		}
	}
}

pub fn (tree Tree) book_exists(name string) bool {
	_ := tree.book_get(name) or {
		if err is BookNotFound {
			return false
		} else {
			panic(err) // catch unforseen errors
		}
	}
	return true
}
