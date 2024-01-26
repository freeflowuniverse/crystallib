module dagu

import freeflowuniverse.crystallib.core.play
// import freeflowuniverse.crystallib.ui
// import freeflowuniverse.crystallib.ui.console

@[params]
pub struct PlayConfig {
pub mut:
	instance    string
	addr 		string
	port 		int
	secret 		string
}

// return a config object even if from partial info
pub fn config(args PlayConfig) PlayConfig {
	return args
}

@[params]
pub struct ConfiguratorGetArgs {
pub mut:
	instance    string = "default"
	context_name      string = 'default'
}


// get the configurator
pub fn configurator(args ConfiguratorGetArgs) !play.Configurator[PlayConfig] {

	mut session:=play.session_new(
		context_name:args.context_name
	)!

	mut c := play.configurator_new[PlayConfig](
		name: 'dagu'
		instance: args.instance
		context: &session.context
	)!
	return c
}