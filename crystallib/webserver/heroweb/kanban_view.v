module heroweb

import veb

@['/kanban']
pub fn (app &App) kanban(mut ctx Context) veb.Result {
	data := kanban_example()
	d := $tmpl('templates/kanban.html')
	return ctx.html(d)
}
