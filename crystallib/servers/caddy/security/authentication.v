module security

import os
import freeflowuniverse.crystallib.core.pathlib


// [params]
// pub struct AuthenticationPortalParams {
// 	UIConfigParams
// }

// pub fn authentication_portal(portal AuthenticationPortal, params AuthenticationPortalParams) !AuthenticationPortal {	
// 	return AuthenticationPortal{
// 		...portal
// 		crypto: Crypto{
// 			default_token_lifetime: 3600
// 		}
// 		ui: ui_config(portal.ui, params.UIConfigParams)
// 		enable_identity_providers: ['generic']
// 		cookie_domain: config.cookie_domain
		
// 	}
// }

// [params]
// pub struct UIConfigParams {
// 	display_ui bool = false// whether the ui should be displayed
// }

// pub fn ui_config(config UIConfig, params UIConfigParams) UIConfig {
// 	if !params.display_ui {
// 		export_login_template(login_template_path)!
// 	}
// 	return config
// }

// pub fn (mut portal AuthenticationPortal) add_user_transform(transform UserTransform) {
// 	portal.transforms << transform
// }

// pub fn (mut portal AuthenticationPortal) assign_email_role(email string, role string) {
// 	portal.transforms << UserTransform{
// 		match_realm: 'gitea'
// 		match_email: email
// 		action: 'add role'
// 		role: role
// 	}
// }


fn export_login_template(path string) ! {
	mut file := pathlib.get_file(path: path, create: true)!
	file.write($tmpl('./templates/login.html'))!
}
