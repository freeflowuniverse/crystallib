#!/usr/bin/env -S v -w -enable-globals run


// import freeflowuniverse.crystallib.installers.mdbook
import freeflowuniverse.crystallib.installers.web.caddy

// shortcut to install the base

mut caddy := caddy.get_install()!

caddy.configure_webserver_default('/var/www', 'd.threefold.me i.threefold.me')!

c := caddy.configuration_get()!
println(c)



