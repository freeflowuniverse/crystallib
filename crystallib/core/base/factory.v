module base

@[params]
pub struct SessionNewArgs {
pub mut:
	instance     string
	context      ?&Context @[skip; str: skip]
	session      ?&Session @[skip; str: skip]
	context_name string = 'default'
	session_name string // default will be based on a date when run
	interactive  bool = true // can ask questions, default on true
	coderoot     string // this will define where all code is checked out
}

pub fn get_session_new_args(args SessionNewArgs) SessionNewArgs {
	return args
}
