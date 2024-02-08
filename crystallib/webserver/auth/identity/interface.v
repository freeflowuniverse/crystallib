module identity

pub interface IIdentity {
mut:
	register(User) !string
}
