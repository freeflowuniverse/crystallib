module publisher

struct PublisherErrors {
pub mut:
	site_errors []SiteError
	page_errors map[string][]PageError
}

// this is used to write json to the flatten dir so the webserver can process defs
struct PublisherDefs {
mut:
	defs []PublisherDef
}

struct PublisherDef {
	def  string
	page string
	site string
}

pub fn (mut publisher Publisher) errors_get(site Site) ?PublisherErrors {
	mut errors := PublisherErrors{}

	// collect all errors in a datastruct
	for err in site.errors {
		errors.site_errors << err
		// TODO: clearly not ok, the duplicates files check is not there
		// if err.cat != SiteErrorCategory.duplicatefile && err.cat != SiteErrorCategory.duplicatepage {
		// 	errors.site_errors << err
		// }
	}

	for name, page_id in site.pages {
		page := publisher.page_get_by_id(page_id)?
		if page.errors.len > 0 {
			errors.page_errors[name] = page.errors
		}
	}

	return errors
}

[if debug ?]
fn trace_progress(msg string) {
	println(msg)
}

// $if debug {eprintln(@FILE + ':' + @LINE + ":" + @FN " - something")}
