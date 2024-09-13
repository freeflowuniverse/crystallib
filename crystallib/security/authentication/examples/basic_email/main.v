module main

import freeflowuniverse.spiderlib.auth.email
import os
import vweb

fn main() {
	dir := os.dir(@FILE)
	if !os.exists('${dir}/static') {
		os.mkdir('${dir}/static')!
	}
	os.chdir('${dir}/static')!
	os.execute('curl -sLO https://raw.githubusercontent.com/freeflowuniverse/weblib/main/htmx/htmx.min.js')

	// create and run app with authenticator
	mut app := &EmailApp{
		auth: email.new(
			backend: email.new_memory_backend()!
		)
	}
	app.mount_static_folder_at('${dir}/static', '/static')
	vweb.run(app, 8080)
}
