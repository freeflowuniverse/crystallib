module data
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

pub struct Actor{
pub mut:
	name string
	models []&Model
	path pathlib.Path
}

pub fn (mut a Actor) model_find(name0 string) []&Model{
	name:=texttools.name_fix(name0)
	mut res := []&Model{}
	for model in a.models{
		if model.name_lower == name{
		res << model
		}			
	}
	return res
}

pub fn (mut a Actor) model_get(name0 string) !&Model{
	mut res:=a.model_find(name0)
	if res.len==1{
		return res[0]
	}
	return error("found ${res.len} nr of models with name $name0 in actor, should have been one.")
}