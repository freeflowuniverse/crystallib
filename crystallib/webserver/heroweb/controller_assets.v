module heroweb

import veb
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.webserver.log
import time

@['/assets']
pub fn (mut app App) assets(mut ctx Context) veb.Result {
	ptrs := app.db.authorized_ptrs(ctx.user_id, .read) or {
		return ctx.server_error(err.str())
	}
	docs := ptrs.map(Document{
		title: it.name.title()
		description: it.description
		url: '/view/asset/${it.name}'
		kind: it.cat.str()
	})

	return ctx.json(docs)
}

// this endpoint serves assets dynamically
@['/asset/:paths...']
pub fn (app &App) asset(mut ctx Context, paths string) veb.Result {
	name := paths.all_before('/')
	infoptr := app.db.infopointers[name] or {
		return ctx.not_found()
	}

	mut path := pathlib.get('${infoptr.path_content}${paths.all_after(name)}') 

	logger := log.new('logger.sqlite') or {
		return ctx.server_error(err.str())
	}
	if infoptr.cat == .website && ctx.req.url.ends_with('.html') {
		logger.new_log(log.Log{
			object: infoptr.name
			timestamp: time.now() 
			subject: ctx.user_id.str() 
			message: 'access path ${ctx.req.url}'
			event: 'view'
		}) or {
			return ctx.server_error(err.str())
		}
	}

	file := if path.is_file() {
		path
	} else {
		// mount the folder 'static' at path '/public', the path has to start with '/'
		pathlib.get_file(path: '${path.path}/index.html') or {
			return ctx.server_error(err.str())
		}
	}
	return ctx.file(file.path)
}
