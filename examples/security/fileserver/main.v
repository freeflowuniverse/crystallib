module main

import freeflowuniverse.crystallib.security.authentication
import freeflowuniverse.crystallib.security.authorization {AccessControlEntry}
import veb

pub fn main() {
	do() or {panic(err)}
}

pub fn do() ! {
	mut authorizer := authorization.new()!
	
	authorizer.add_access_control(
		resource: 'some_resource'
		user_acl: [
			AccessControlEntry{
				user_id: os.getenv('TEST_EMAIL1')
				permissions: [.read, .write]
			}, AccessControlEntry{
				user_id: os.getenv('TEST_EMAIL2')
				permissions: [.read, .write]
			}
		]
	)!

	mut app := new_app(
		authorizer: authorizer
		authenticator: authentication.new_client(
			url: 'http://localhost:8082'
		)
	)!

    mut authentication_server := authentication.new_server(
		base_url: 'http://localhost:8082'
		secret: 'abcd'
		smtp_client: get_smtp_client()
	)!

	spawn authentication_server.run(8082)
	app.run(8081)
}