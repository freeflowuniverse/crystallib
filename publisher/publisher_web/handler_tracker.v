
module publisher_web

//THIS is the code which gives us a log about who is visiting our publishing server
import vweb
import json
import time
import os

struct Tracker {
mut:
	id    string
	state string
	url   string
	page  string [json: 'hash']
}


// Get user ip without temperary port
// we need this to log
fn (mut app App) user_ip() string {
	// Get user ip returned without the temp port, like [::1]:81152
	mut user_ip := app.ip()
	ind := user_ip.last_index(':') or { user_ip.len }

	// In this line we take the ip part only without port
	user_ip = user_ip.substr(0, ind)
	return user_ip
}

['/tracker'; post]
pub fn (mut app App) handle_tracker() vweb.Result {
	mut tracker := json.decode(Tracker, app.req.data) or {
		app.set_status(400, 'Bad Request')
		return app.json('{"status": "error", "message": "failed to decode data with error: $err"}')
	}

	mut ctx := rlock app.ctx {
		app.ctx
	}	

	varpath := ctx.config.publish.paths.var


	// Time to be used in logs
	time_now := time.now()
	date := time_now.ymmdd().replace('-', '_')
	// Info from request
	// trim / from id and page
	tracker.id = tracker.id.trim('/')
	tracker.page = if tracker.page.trim('/') == '' { 'home' } else { tracker.page.trim('/') }
	// Get wiki name from url
	wiki_name := wiki_name_from_url(tracker.url)

	// Get user ip
	user_ip := app.user_ip()

	// Constract file path
	logs_dir := varpath + '/logs/' + wiki_name

	// Make sure logs dir exists
	if !os.exists(logs_dir) {
		os.mkdir_all(logs_dir) or {
			app.set_status(500, 'Internal Error')
			return app.json('{"status": "error", "message": "failed to create log dir with error: $err"}')
		}
	}

	file_path := logs_dir + '/' + tracker.id + '__${date}.log'
	mut log_file := os.open_append(file_path) or {
		app.set_status(500, 'Internal Error')
		return app.json('{"status": "error", "message": "failed to open file with error: $err"}')
	}

	// Constract log value
	value := '$time_now\t $user_ip\t $tracker.state\t $tracker.page'

	// Append value to log file
	log_file.writeln(value) or {
		app.set_status(500, 'Internal Error')
		return app.json('{"status": "error", "message": "failed to write log value with error: $err"}')
	}

	// Flush and close the file
	log_file.flush()
	log_file.close()

	return app.ok('')
}
