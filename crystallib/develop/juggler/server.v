module juggler

import freeflowuniverse.crystallib.servers.daguserver
import freeflowuniverse.crystallib.servers.caddy
import freeflowuniverse.crystallib.webserver.auth.jwt { SignedJWT }
import veb
import os

pub struct Context {
	veb.Context
}

pub fn (mut j Juggler) run(port int) ! {
	mut c := caddy.get(j.name)!
	c.start()!

	mut d := daguserver.get(j.name)!
	d.start()!

	j.serve_static('/static/tf_juggler_light.png', '${os.dir(@FILE)}/static/tf_juggler_light.png')!
	j.route_use('/', handler: is_authenticated)
	j.route_use('/scripts', handler: is_authenticated)
	j.route_use('/script:', handler: is_authenticated)
	j.route_use('/triggers', handler: is_authenticated)
	j.route_use('/triggers:', handler: is_authenticated)
	j.route_use('/plays', handler: is_authenticated)
	j.route_use('/plays:', handler: is_authenticated)
	j.route_use('/settings', handler: is_authenticated)
	j.route_use('/activity', handler: is_authenticated)

	// scripts := j.load_scripts() or {panic('this should never happen ${error}')}
	// for key, script in scripts {
	// 	j.scripts[script.name] = script
	// }

	veb.run[Juggler, Context](mut j, port)
}

pub fn is_authenticated(mut ctx Context) bool {
	access_cookie := ctx.get_cookie('access_token') or {
		ctx.redirect('/login')
		return false
	}

	token := SignedJWT(access_cookie)
	verified := token.verify(jwt_secret) or {
		ctx.redirect('/login')
		return false
	}

	if !verified {
		ctx.redirect('/login')
		return false
	}
	return true
}
