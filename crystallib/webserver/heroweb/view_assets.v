module heroweb

import veb
import freeflowuniverse.crystallib.core.pathlib

@['/view/assets']
pub fn (app &App) view_assets(mut ctx Context, name string) veb.Result {
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
			slides := Slides{
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