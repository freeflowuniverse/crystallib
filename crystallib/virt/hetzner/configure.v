module hetzner

import freeflowuniverse.crystallib.core.base

@[heap]
pub struct HetznerConfig {
pub mut:
	instance string
	user     string
	pass     string
	base     string
}

fn configurator(instance string, mut session base.Session) !play.Configurator[HetznerConfig] {
	mut c := play.configurator_new[HetznerConfig](
		name: 'hetzner'
		instance: instance
		context: &session.context
	)!
	return c
}
