module config

pub struct OpenGraph {
pub mut:
	title        string
	description  string
	url          string
	type_        string = 'article'
	image        string
	image_width  string = '1200'
	image_height string = '630'
}
