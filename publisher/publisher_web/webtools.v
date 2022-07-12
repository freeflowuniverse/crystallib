
module publisher_web



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