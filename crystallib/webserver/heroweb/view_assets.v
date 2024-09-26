module heroweb

import veb
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.webserver.components

pub struct Row {
pub:
	cells []Cell
}

pub struct Cell {
pub:
	content string
}

pub struct Table {
pub:
	rows []Row
}

pub fn (component Row) html() string {
	return "<tr>\n${component.cells.map(it.html()).join('\n')}\n</tr>"
}

pub fn (component Cell) html() string {
    return "<td>${component.content}</td>"
}

@['/view/assets']
pub fn (mut app App) view_assets(mut ctx Context, name string) veb.Result {
	
	ptrs := app.db.authorized_ptrs(ctx.user_id, .read) or {
		return ctx.server_error(err.str())
	}

	rows := ptrs.map(
		Row {
			cells: [
				Cell{'icon_html'}
				Cell{it.name}
				Cell{it.description}
				Cell{it.tags.map(it).join(',')}
				Cell{it.cat.str()}
			]
		}
	)

	table := Table {
		rows: rows
	}

	return ctx.html($tmpl('./templates/assets.html'))
}

@['/view/asset/:name']
pub fn (app &App) view_asset(mut ctx Context, name string) veb.Result {
	if name !in app.db.infopointers {
		return ctx.server_error('Asset with name ${name} not found')
	}

	infoptr := app.db.infopointers[name]

	if infoptr.cat == .website {
		return ctx.redirect('/asset/${name}/index.html')
	}

	html := match infoptr.cat {
		.pdf {
			comp := components.PDFViewer{
				name: name
				pdf_url: '/asset/${name}'
				log_endpoint: '/log/${name}'
			}
			comp.html()
		} .slides {
			slides := components.Slides{
				url:'/asset/${name}'
				log_endpoint: '/log/${name}'
				name: name
			}
			slides.html()
		} else {
				return ctx.server_error('unsupported infoptr category ${infoptr.cat}')
			}
		}
	return ctx.html(html)
}