module knowledgetree

import freeflowuniverse.crystallib.core.texttools

pub enum PointerCat {
	page
	image
	video
	file
	html
}

pub enum PointerState {
	unknown
	ok
	error
}

// links to a page, image or file
pub struct Pointer {
pub mut:
	sid        string // is the smartid name only relevant into my 3bot, each pointer can have unique sid
	collection string // all namefixed
	book       string
	name       string // is name without extension, all namefixed (lowercase...)
	cat        PointerCat
	state      PointerState
	extension  string // e.g. jpg
	error      string // if there is an error on the pointer, then will be visible in this property
	tree       string
}

// will return a clean pointer to a page, image or file
//
// input is e.g. mycollectionname:filename.jpg or  mycollectionname:filename._jpg
// 	or filename.jpg
// 	or mypage.md
// input can also include a bookname or bookid e.g. bookname:collectionname:filename.jpg
// if collectionname is not known but want to specify bookname do bookname::filename.jpg,
// 		now the filename can only be found if unique in the full book
//      bookname can be id of book or name, name needs to be specified in my 3bot
//
// if is image will remove extension and last _ (before extension)
// all will be lowercase as well
pub fn pointer_new(txt_ string) !Pointer {
	mut p := Pointer{}
	mut txt := txt_.trim_space().replace('\\', '/').replace('//', '/').all_after_last('/')

	// take colon parts out
	nrcolon := txt.count(':')
	splitted_colons := txt.split(':')
	if nrcolon > 2 {
		return error("pointer can only have 2 ':' inside. ${txt}")
	} else if nrcolon == 2 {
		p.book = texttools.name_fix_keepext(splitted_colons[0])
		p.collection = texttools.name_fix_keepext(splitted_colons[1])
		p.name = texttools.name_fix_keepext(splitted_colons[2])
	} else if nrcolon == 1 {
		p.collection = texttools.name_fix_keepext(splitted_colons[0])
		p.name = texttools.name_fix_keepext(splitted_colons[1])
	} else {
		p.name = texttools.name_fix_keepext(splitted_colons[0])
	}

	// define extension
	nrdot := p.name.count('.')
	if nrdot > 1 {
		return error("pointer can only have 1 '.' inside. ${p.name}")
	} else if nrdot == 0 {
		// no extension so needs to be markdown
		p.cat = .page
	} else if nrdot == 1 {
		// now need to check if we find imagename
		splitted := p.name.split('.')
		p.extension = splitted[1].to_lower()
		if p.extension == 'md' {
			p.cat = .page
		} else if p.extension in ['jpg', 'jpeg', 'svg', 'gif', 'png'] {
			p.cat = .image
		} else if p.extension in ['mp4', 'mov'] {
			p.cat = .image
		} else {
			p.cat = .file
		}
		p.name = splitted[0]
	}

	if p.cat == .image || p.cat == .page {
		p.name = p.name.trim_right('_')
	}

	return p
}

// represents the pointer in minimal string format
pub fn (p Pointer) str() string {
	mut out := ''

	if p.book.len > 0 {
		out = '${p.book}:${p.collection}:${p.name}'
	} else if p.collection.len > 0 {
		out = '${p.collection}:${p.name}'
	} else {
		out = p.name
	}

	if p.extension.len > 0 {
		out += '.${p.extension}'
	}
	return out
}

pub fn (p Pointer) is_image() bool {
	return p.cat == .image
}

pub fn (p Pointer) is_file_video_html() bool {
	return p.cat == .image || p.cat == .file || p.cat == .video
}
