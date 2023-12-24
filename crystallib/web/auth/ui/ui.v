module ui

import vweb
import freeflowuniverse.crystallib.web.auth.identity

pub struct AuthUI {
	vweb.Context
	users []identity.User
}

pub fn (mut ui AuthUI) index() vweb.Result {
	return $vweb.html()
}

pub fn (mut ui AuthUI) users() vweb.Result {
	return $vweb.html()
}
