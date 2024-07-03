module caddy

pub fn authentication_portal(config AuthenticationPortal) AuthenticationPortal {
	return AuthenticationPortal{
		name: config.name
		crypto: Crypto{
			default_token_lifetime: 3600
		}
		enable_identity_providers: ['generic']
		cookie_domain: config.cookie_domain
		ui_links: [
			UILink{
				label: 'My Identity'
				url: '/whoami'
				icon: 'las la-user'
			},
		]
	}
}

pub fn (mut portal AuthenticationPortal) add_user_transform(transform UserTransform) {
	portal.transforms << transform
}

pub fn (mut portal AuthenticationPortal) assign_email_role(email string, role string) {
	portal.transforms << UserTransform{
		match_realm: 'gitea'
		match_email: email
		action: 'add role'
		role: role
	}
}
