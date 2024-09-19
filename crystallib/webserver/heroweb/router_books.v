module heroweb

import veb
import freeflowuniverse.crystallib.core.pathlib

@['/documents/view_book/:name']
pub fn (app &App) view_book(mut ctx Context, name string) veb.Result {
	slides := Slides{url:'/book/${name}', name: name}
	return ctx.html(slides.html())
}

@['/documents/book/:name']
pub fn (app &App) book(mut ctx Context, name string) veb.Result {
	infoptr := app.db.infopointers[name] or {
		return ctx.not_found()
	}

	file := pathlib.get_file(path: infoptr.path_content) or {
		return ctx.server_error(err.str())
	}
	println('file ${file} \n infoptr ${infoptr}')
	ctx.set_content_type('application/pdf')
	return ctx.file(file.path)
}

pub struct Book {
	title string
	description string
	url string
}

@['/documents/books']
pub fn (mut app App) books(mut ctx Context) veb.Result {
	ptrs := app.db.authorized_ptrs(ctx.user_id, .read) or {
		return ctx.server_error(err.str())
	}
	books := ptrs.filter(it.cat == .wiki).map(Book{
		title: it.name.title()
		description: it.description
		url: '/documents/view_pdf/${it.name}'
	})
	return ctx.json(books)
}