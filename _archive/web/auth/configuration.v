module auth

pub fn (mut auth Authenticator) register_admin(email string) {
	user := auth.identity.register_user(email)
	// auth.authorizer.add_admin(user.id)
}
