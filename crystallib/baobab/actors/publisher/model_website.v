module publisher

import freeflowuniverse.crystallib.webtools.zola
import freeflowuniverse.crystallib.baobab.base

pub struct Website {
	base.Base
	name string
	title string
	description string
	framework WebsiteFramework
pub mut:
	pages []Page
	sections []Section
}

pub enum WebsiteFramework {
	zola
	astro
}

pub struct Page {
	name string
	title string
	description string
	template string
	source string
}

pub struct Section {
	name string
	title string
	description string
	template string
	content_source string
	pages []Page
}