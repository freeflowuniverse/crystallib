module hetzner

import freeflowuniverse.crystallib.core.play

@[heap]
pub struct HetznerConfig {
pub mut:
	instance string
	user string
	pass string
	base string
}

fn configurator(instance string, mut session play.Session) !play.Configurator[HetznerConfig] {
	mut c := play.configurator_new[HetznerConfig](
		name: 'hetzner'
		instance: instance
		context: &session.context
	)!
	return c
}
