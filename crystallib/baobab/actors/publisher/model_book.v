module publisher

import freeflowuniverse.crystallib.webtools.zola
import freeflowuniverse.crystallib.baobab.base

pub struct Book {
	base.Base
	framework WebsiteFramework
	pages []Page
	sections []Section
}
