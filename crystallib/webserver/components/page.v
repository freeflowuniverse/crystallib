module components

pub struct Page {
pub:
	heading PageHeading
	content IComponent
}

pub fn (page Page) html() string {
	return $tmpl('./templates/page.html')
}

pub struct PageHeading {
pub:
	title string
}

pub fn (heading PageHeading) html() string {
	return '<header>\n\t<h1>${heading.title}</h1>\n</header>'
}