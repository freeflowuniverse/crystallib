module modelgenerator

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools

pub struct CodeGenerator {
pub mut:
	path_in  pathlib.Path
	path_out pathlib.Path
	domains  []&Domain
}

// can use domain.actor.modelname or actor.modelname or modelname
pub fn (mut generator CodeGenerator) model_find(name0 string) ![]Model {
	mut name := texttools.name_fix(name0)
	splitted := name.split('.')
	mut domainname := ''
	mut actorname := ''
	if splitted.len > 3 {
		return error('can max have 2 . in name of a model is domain.actor.modelname')
	} else if splitted.len == 2 {
		domainname = splitted[0]
		actorname = splitted[1]
		name = splitted[0]
	} else if splitted.len == 1 {
		actorname = splitted[1]
		name = splitted[0]
	}
	mut res := []Model{}
	for domain in generator.domains {
		if domainname.len > 0 && domainname != domain.name {
			// means domainname was specified but not in line with current domain so skip
			continue
		}
		for actor in domain.actors {
			if actorname.len > 0 && actorname != actor.name {
				// means actorname was specified but not in line with current actor so skip
				continue
			}
			for model in actor.models {
				if model.name_lower == name {
					res << model
				}
			}
		}
	}
	return res
}

pub fn (mut generator CodeGenerator) model_get(name0 string) !Model {
	mut res := generator.model_find(name0)!
	if res.len == 1 {
		return res[0]
	}
	return error('found ${res.len} nr of models with name ${name0}, should have been one.')
}
