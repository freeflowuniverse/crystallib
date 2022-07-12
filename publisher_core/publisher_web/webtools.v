
module publisher_web

fn wiki_name_from_url(url string) string {
	url_splitted := url.split('/')
	mut wiki_name := ''
	for id, element in url_splitted {
		if element == 'info' {
			wiki_name = url_splitted[id + 1].split('?')[0]
		}
	}
	return wiki_name
}



fn content_type_get(path string) ?string {
	if path.ends_with('.css') {
		return 'text/css'
	}
	if path.ends_with('.js') {
		return 'text/javascript'
	}
	if path.ends_with('.svg') {
		return 'image/svg+xml'
	}
	if path.ends_with('.png') {
		return 'image/png'
	}
	if path.ends_with('.jpeg') || path.ends_with('.jpg') {
		return 'image/jpg'
	}
	if path.ends_with('.gif') {
		return 'image/gif'
	}
	if path.ends_with('.pdf') {
		return 'application/pdf'
	}

	if path.ends_with('.zip') {
		return 'application/zip'
	}

	if path.ends_with('.html') {
		return 'text/html'
	}

	return error('cannot find content type for $path')
}