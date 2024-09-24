module heroweb

import veb
import freeflowuniverse.crystallib.webserver.components

@['/view/kanban']
pub fn (app &App) view_kanban(mut ctx Context) veb.Result {
	component := components.kanban_example()
	return ctx.html(component.html())
}
