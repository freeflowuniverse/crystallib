module juggler

import freeflowuniverse.crystallib.servers.caddy

pub fn get(j Juggler) !&Juggler {
	c := caddy.get('')!
	// c.start()!

	return &Juggler{...j}
}