module heroweb

import json
import veb
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.webserver.log

@[GET; '/view/logs']
pub fn (mut app App) view_logs(mut ctx Context) veb.Result {
    return ctx.html($tmpl('./templates/logs.html'))
}
