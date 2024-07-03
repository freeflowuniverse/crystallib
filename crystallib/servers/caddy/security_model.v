module caddy

pub struct Security {
pub mut:
	https_port     int
	orders         []Order
	oauth_provider OAuthProvider
	authentication AuthenticationPortal
	authorization  AuthorizationPolicy
}

pub struct Order {
pub mut:
	directive1 string
	directive2 string
}

pub struct OAuthProvider {
pub mut:
	realm              string
	driver             string
	domain_name        string
	client_id          string
	client_secret      string
	scopes             []string
	base_auth_url      string
	metadata_url       string
	user_group_filters []string
}

pub struct AuthenticationPortal {
pub mut:
	name                      string
	crypto                    Crypto
	enable_identity_providers []string
	cookie_domain             string
	ui_links                  []UILink
	transforms                []UserTransform
}

pub struct Crypto {
pub mut:
	default_token_lifetime int
	sign_verify_key        string
}

pub struct UILink {
pub mut:
	label string
	url   string
	icon  string
}

pub struct UserTransform {
pub mut:
	match_realm string
	match_email string
	action      string
	role        string
	ui_link     UILink
}

pub struct AuthorizationPolicy {
pub mut:
	name              string
	auth_url          string
	crypto_key_verify string
	allowed_roles     []string
	validate_bearer   bool
	inject_headers    bool
}
