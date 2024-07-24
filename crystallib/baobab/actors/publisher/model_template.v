module publisher

import freeflowuniverse.crystallib.baobab.base

pub struct Template {
	base.Base
	name string
	url string
}

pub fn (mut p Publisher[Config]) import_templates(template Template) ! {
	p.backend.new[Template](template)!
}