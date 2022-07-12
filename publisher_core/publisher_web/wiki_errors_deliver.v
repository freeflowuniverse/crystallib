
module publisher_web


import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.publisher_core
import os
import vweb
import json
import time


//return the htlm file with all errors
fn (mut app App) return_html_errors (publisher &Publisher, sitename string) vweb.Result {
	t := error_template(publisher, sitename)
	if t.starts_with('ERROR:') {
		return app.server_error(4)
	}
	// println(t)
	return app.ok(t)
}

fn error_template(mut publisher &Publisher, sitename string) string {

	mut errors := publisher_core.PublisherErrors{}
	mut site := publisher.site_get(sitename) or {
		return 'cannot get site, in template for errors\n $err'
	}
	if publisher.develop {
		errors = publisher.errors_get(site) or {
			return 'ERROR: cannot get errors, in template for errors\n $err'
		}
	} else {
		path2 := os.join_path(publisher.config.publish.paths.publish, 'wiki_$sitename', 'errors.json')
		err_file := os.read_file(path2) or { return 'ERROR: could not find errors file on $path2' }
		errors = json.decode(PublisherErrors, err_file) or {
			return 'ERROR: json not well formatted on $path2'
		}
	}
	mut site_errors := errors.site_errors
	mut page_errors := errors.page_errors.clone()
	return $tmpl('errors.html')
}