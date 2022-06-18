module actionparser
import texttools
import os

pub struct ActionsParser {
pub mut:
	actions []Action
}

pub struct Action {
pub:
	name string
pub mut:
	params []Param
}

struct Param {
pub:
	name  string
	value string
}

//get the param as string, if it does not exist will throw error
pub fn (action Action) param_get(name_ string) ?string {

	mut name := texttools.name_fix(name_)
	mut val:=""
	for param in action.params{
		if param.name==name{
			val = param.value
		}
	}
	if val == ""{
		return error("could not find param with name: $name_")
	}

	return val
}



//will get path and check it exists
pub fn (action Action) param_path_get(name_ string) ?string {

	path := action.param_get(name_)?

	if ! os.exists(path){
		return error("Cannot find path: $name_")
	}

	return path
}



//will get path and check it exists if not will create
pub fn (action Action) param_path_get_create(name_ string) ?string {

	path := action.param_get(name_)?

	if ! os.exists(path){
		os.mkdir_all(path)?
	}

	return path
}

