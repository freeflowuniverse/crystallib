module heroweb

import veb

pub struct Slides {
pub:
	url string
	name string
	log_endpoint string
}

pub fn (slides Slides) html() string {
	return $tmpl('templates/slides.html')
}