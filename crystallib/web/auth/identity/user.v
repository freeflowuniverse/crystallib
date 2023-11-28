module identity

import db.sqlite

pub struct IdentityManager {
mut:
	backend DBBackend
}

pub fn new() !IdentityManager {
	return IdentityManager{
		backend: new_backend()!
	}
}

pub struct User {
pub:
	id string @[primary]
pub mut:
	email string
}

pub fn (mut auth IdentityManager) login_user(email string) ?User {
	return auth.backend.read_user(email: email)
}

pub fn (mut auth IdentityManager) register_user(email string) User {
	return auth.backend.create_user(email)
}

pub fn (mut auth IdentityManager) get_user(user User) ?User {
	return auth.backend.read_user(
		id: user.id
		email: user.email
	) or { return none }
}
