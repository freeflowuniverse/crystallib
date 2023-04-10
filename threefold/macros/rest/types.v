module rest

pub interface WithContent {
	content string
}

pub struct Blog {
pub mut:
	id            string
	title         string
	tags          []string
	category      []string
	image         string
	image_caption string
	excerpt       string
	authors       []string
	// should be a datetime or equivalent, but it's actually a string one
	// in meta data
	created string

	content string
}

pub type News = Blog

pub struct Project {
pub mut:
	id            string
	title         string
	countries     []string
	cities        []string
	rank          int
	excerpt       string
	image         string
	image_caption string
	logo          string
	category      []string
	members       []string
	websites      string
	tags          []string
	private       int
	linkedin      string

	content string
}

pub struct Person {
pub mut:
	id          string
	name        string
	rank        int
	memberships []string
	category    []string
	bio         string
	excerpt     string
	linkedin    string
	websites    string
	image       string
	projects    []string
	countries   []string
	cities      []string
	private     int

	content string
}
