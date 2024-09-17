module heroweb



@['/wiki']
pub fn (app &App) hello_user(mut ctx Context, user string) veb.Result {
	doc := model_web_example()
	d := $tmpl('templates/index.html')
	return ctx.html(d)
}
