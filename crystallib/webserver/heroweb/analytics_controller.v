module heroweb

import json
import veb
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.webserver.log {Log}

@[POST; '/analytics/:name']
pub fn (mut app App) analytics_document_post(mut ctx Context, name string) veb.Result {
	infoptr := app.db.infopointers[name] or {
		return ctx.not_found()
	}

	new_log := json.decode(Log, ctx.req.data) or {
		return ctx.server_error(err.str())
	}
	app.db.logger.new_log(Log{...new_log, subject: ctx.user_id.str()}) or {
		return ctx.server_error(err.str())
	}

	return ctx.json('ok')
}

@['/analytics/:name']
pub fn (mut app App) analytics_document_get(mut ctx Context, name string) veb.Result {
	logs := app.db.logger.get_logs(object: name) or {
		return ctx.not_found()
	}

	return ctx.json(logs)
}
