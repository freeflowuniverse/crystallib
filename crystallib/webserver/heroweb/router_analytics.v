module heroweb

import veb
import freeflowuniverse.crystallib.core.pathlib

// @['/documents']
// pub fn (app &App) documents(mut ctx Context, name string) veb.Result {
// 	return ctx.html($tmpl('./templates/documents.html'))
// }

// @['/documents/view_pdf/:name']
// pub fn (app &App) view_pdf(mut ctx Context, name string) veb.Result {
// 	slides := Slides{'/pdf/${name}'}
// 	return ctx.html(slides.html())
// }

// @['/documents/pdf/:name']
// pub fn (app &App) pdf(mut ctx Context, name string) veb.Result {
// 	infoptr := app.db.infopointers[name] or {
// 		return ctx.not_found()
// 	}

// 	file := pathlib.get_file(path: infoptr.path_content) or {
// 		return ctx.server_error(err.str())
// 	}
// 	println('file ${file} \n infoptr ${infoptr}')
// 	ctx.set_content_type('application/pdf')
// 	return ctx.file(file.path)
// }

// @['/documents/pdf/:name/analytics']
// pub fn (app &App) pdf_analytics(mut ctx Context, name string) veb.Result {
// 	infoptr := app.db.infopointers[name] or {
// 		return ctx.not_found()
// 	}

// 	file := pathlib.get_file(path: infoptr.path_content) or {
// 		return ctx.server_error(err.str())
// 	}
// 	println('file ${file} \n infoptr ${infoptr}')
// 	ctx.set_content_type('application/pdf')
// 	return ctx.file(file.path)
// }

// pub struct PDF {
// 	title string
// 	description string
// 	url string
// }

// @['/documents/pdfs']
// pub fn (mut app App) pdfs(mut ctx Context) veb.Result {
// 	ptrs := app.db.authorized_ptrs(ctx.user_id, .read) or {
// 		return ctx.server_error(err.str())
// 	}
// 	pdfs := ptrs.filter(it.cat == .pdf).map(PDF{
// 		title: it.name.title()
// 		description: it.description
// 		url: '/documents/view_pdf/${it.name}'
// 	})
// 	return ctx.json(pdfs)
// }