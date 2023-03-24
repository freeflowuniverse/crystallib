module data

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

pub struct Actor {
pub mut:
	name   string
	models []Model
	path   pathlib.Path
}

fn (mut a Actor) model_find(name0 string) []Model {
	name := texttools.name_fix(name0)
	mut res := []Model{}
	for model in a.models {
		if model.name_lower == name {
			res << model
		}
	}
	return res
}

// this only looks at the local level
pub fn (mut a Actor) model_get(name0 string) !Model {
	mut res := a.model_find(name0)
	if res.len == 1 {
		return res[0]
	}
	return error('found ${res.len} nr of models with name ${name0} in actor, should have been one.')
}

// wil try to find the model, starting from actor, then domain then generator
fn (mut actor Actor) model_get_priority(mut generator CodeGenerator, mut domain Domain, modelname_inherit string) !Model {
	mut model_inherit := Model{}
	if actor.model_find(modelname_inherit).len == 1 {
		model_inherit = actor.model_get(modelname_inherit)!
	} else if domain.model_find(modelname_inherit).len == 1 {
		model_inherit = actor.model_get(modelname_inherit)!
	} else if generator.model_find(modelname_inherit)!.len == 1 {
		model_inherit = actor.model_get(modelname_inherit)!
	} else {
		return error('cannot find mode: ${modelname_inherit}')
	}
	return model_inherit
}
