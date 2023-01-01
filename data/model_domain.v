module data
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

pub struct Domain{
pub mut:
	name string
	path pathlib.Path
	actors []&Actor	
}

pub fn (mut d Domain) model_find(name0 string) []&Model{
	name:=texttools.name_fix(name0)
	mut res := []&Model{}
	for _,actor in d.actors{
		for model in actor.models{
			if model.name_lower == name{
			res << model
			}			
		}
	}
	return res
}

pub fn (mut d Domain) model_get(name0 string) !&Model{
	mut res:=d.model_find(name0)
	if res.len==1{
		return res[0]
	}
	return error("found ${res.len} nr of models with name $name0, should have been one.")
}