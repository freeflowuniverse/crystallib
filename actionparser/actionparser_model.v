module actionparser

import freeflowuniverse.crystallib.texttools
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

// get the param as string, if it does not exist will throw error
pub fn (action Action) param_get(name_ string) ?string {
	mut name := texttools.name_fix(name_)
	mut val := ''
	for param in action.params {
		if param.name == name {
			val = param.value
		}
	}
	if val == '' {
		return error('could not find param with name: $name_')
	}

	return val
}

pub fn (action Action) param_get_default(name_ string, defval string) string {
	return action.param_get(name_) or {defval}
}

pub fn (action Action) param_get_default_true(name_ string) bool {
	mut r := action.param_get(name_) or {""}
	r = texttools.name_fix_no_underscore(r)
	if r=="" || r=="1" || r=="true" || r=="y"{
		return true
	}
	return false
}

pub fn (action Action) param_get_default_false(name_ string) bool {
	mut r := action.param_get(name_) or {""}
	r = texttools.name_fix_no_underscore(r)
	if r=="" || r=="0" || r=="false" || r=="n"{
		return false
	}
	return true
}

// will get path and check it exists
pub fn (action Action) param_path_get(name_ string) ?string {
	path := action.param_get(name_)?

	if !os.exists(path) {
		return error('Cannot find path: $name_')
	}

	return path
}

// will get path and check it exists if not will create
pub fn (action Action) param_path_get_create(name_ string) ?string {
	path := action.param_get(name_)?

	if !os.exists(path) {
		os.mkdir_all(path)?
	}

	return path
}
