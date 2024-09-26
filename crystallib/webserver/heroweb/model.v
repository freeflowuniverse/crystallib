module heroweb

import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.webserver.auth.jwt
import freeflowuniverse.crystallib.data.markdownparser.elements
import freeflowuniverse.crystallib.webserver.auth.authentication.email {StatelessAuthenticator}
import freeflowuniverse.crystallib.webserver.log {Logger}
import veb

pub struct App {
	veb.StaticHandler
	veb.Middleware[Context]
	veb.Controller
	jwt_secret string = jwt.create_secret()
mut:
	db WebDB
pub:
	base_url string = 'http://localhost:8090'
	secret_key string = '1234'
}

pub struct WebDB {
	Logger
pub mut:
	authenticator StatelessAuthenticator
	users        map[u16]&User
	groups       map[string]&Group
	acls         map[string]&ACL
	infopointers map[string]&InfoPointer
}

pub struct Context {
	veb.Context
pub mut:
	// In the context struct we store data that could be different
	// for each request. Like a User struct or a session id
	user_id       u16
	session_id string
}