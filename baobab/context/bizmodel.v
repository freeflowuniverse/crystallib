module context

import freeflowuniverse.crystallib.bizmodel
import freeflowuniverse.crystallib.texttools

pub fn (mut c Context) bizmodel(name_ string) !bizmodel.BizModel {
	name := texttools.name_fix(name_)
	if name !in c.bizmodels {
		return error("Cannot find bizmodel with name '${name}'")
	}
	return c.bizmodels[name] or { panic(err) }
}

pub fn bizmodel_init(mut c Context, mut actions Actions, action Action) ! {
	mut path := action.params.get_default('url', '')!
	mut url := action.params.get_default('url', '')!
	mut name := action.params.get_default('name', '')!

	c.bizmodels[name] = bizmodel.new(context: mut c, path: path, url: url, name: name)!
}
