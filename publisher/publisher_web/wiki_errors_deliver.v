
module publisher_web

import os
import vweb
import json


//return the htlm file with all errors
fn (mut app App) return_html_errors (sitename string) vweb.Result {
	t := error_template(sitename)
	if t.starts_with('ERROR:') {
		return app.server_error(4)
	}
	// println(t)
	return app.ok(t)
}

//use template to show errors of a wiki
//the errors are read from filesystem
fn error_template(sitepath string) string {

	sitename := os.base(sitepath.trim_right("/"))

	mut errors := Errors{}
	path2 := os.join_path(sitepath, 'errors.json')
	err_file := os.read_file(path2) or { return 'ERROR: could not find errors file on $path2' }
	errors = json.decode(Errors, err_file) or {
		return 'ERROR: json not well formatted on $path2'
	}
	mut site_errors := errors.site_errors
	mut page_errors := errors.page_errors.clone()

	return $tmpl('templates/errors.html')
}