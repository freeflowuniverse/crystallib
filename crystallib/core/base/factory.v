module base

@[params]
pub struct PlayArgs {
pub mut:
	instance            string
	context             ?&Context      @[skip; str: skip]
	session             ?&Session      @[skip; str: skip]
	context_name        string = 'default'
	session_name        string // default will be based on a date when run
	interactive         bool = true // can ask questions, default on true
	coderoot            string // this will define where all code is checked out
	// playbook_url        string // url of heroscript to get and execute in current context
	// playbook_path       string // path of heroscript to get and execute
	// playbook_text       string // heroscript to execute
	// playbook_priorities map[int]string
	// git_pull            bool // if playbook_url used
	// git_reset           bool // if playbook_url used
	// run                 bool
}

pub fn get_play_args(args PlayArgs) PlayArgs {
	return args
}
