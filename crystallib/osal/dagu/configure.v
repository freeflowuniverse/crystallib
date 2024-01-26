module dagu

import freeflowuniverse.crystallib.core.play
// import freeflowuniverse.crystallib.ui
// import freeflowuniverse.crystallib.ui.console

@[params]
pub struct MyConfig {
pub mut:
	instance string
	addr     string
	port     int
	secret   string
}

// return a config object even if from partial info
pub fn config(args Config) MyConfig {
	return args
}

@[params]
pub struct ConfiguratorGetArgs {
pub mut:
	instance     string = 'default'
	context_name string = 'default'
}

// get the configurator
pub fn configurator(args ConfiguratorGetArgs) !play.Configurator[MyConfig] {
	mut session := play.session_new(
		context_name: args.context_name
	)!

	mut c := play.configurator_new[MyConfig](
		name: 'dagu'
		instance: args.instance
		context: &session.context
	)!
	return c
}
