module heroweb

import veb
import freeflowuniverse.crystallib.core.pathlib

@['/assets']
pub fn (mut app App) assets(mut ctx Context) veb.Result {
	ptrs := app.db.authorized_ptrs(ctx.user_id, .read) or {
		return ctx.server_error(err.str())
	}
	docs := ptrs.map(Document{
		title: it.name.title()
		description: it.description
		url: '/view/asset/${it.name}'
	})
	
	return ctx.json(docs)
}

// @['/document/:name']
// pub fn (app &App) document(mut ctx Context, name string) veb.Result {
// 	infoptr := app.db.infopointers[name] or {
// 		return ctx.not_found()
// 	}

// 	path := pathlib.get(infoptr.path_content) 

// 	file := if path.is_file() {
// 		path
// 	} else {
// 		// mount the folder 'static' at path '/public', the path has to start with '/'
// 		pathlib.get_file(path: '${path.path}/index.html') or {
// 			return ctx.server_error(err.str())
// 		}
// 	}

// 	ctx.set_content_type('application/pdf')
// 	return ctx.file(file.path)
// }
