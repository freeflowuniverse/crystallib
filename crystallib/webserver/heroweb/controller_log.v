module heroweb

import json
import veb
import time
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.webserver.log

@[POST; '/log/:name']
pub fn (mut app App) log_post(mut ctx Context, name string) veb.Result {
	infoptr := app.db.infopointers[name] or {
		return ctx.not_found()
	}

	// new_log := json.decode(log.Log, ctx.req.data) or {
	// 	return ctx.server_error(err.str())
	// }
	// app.db.new_log(log.Log{...new_log, 
	// 	subject: ctx.user_id.str()
	// 	timestamp: time.now()
	// }) or {
	// 	return ctx.server_error(err.str())
	// }

	return ctx.json('ok')
}

@[GET; '/logs']
pub fn (mut app App) logs(mut ctx Context) veb.Result {
	// logs := app.db.filter_logs(
	//     event: ctx.query['event'] or { '' }
	// 	subject: ctx.query['subject'] or { '' }
	// 	object: ctx.query['object'] or { '' }
	// ) or {
	// 	return ctx.server_error(err.str())
	// }

    return ctx.json('logs')
}
