module letsencrypt

import os
import time
import freeflowuniverse.crystallib.installers.web.lighttpd as lighttpdinstaller

@[params]
pub struct lentEncryptArgs {
pub mut:
	email  string @[required]
	domain string @[required]
	reset  bool
}

pub fn new(args lentEncryptArgs) !lentEncryptArgs {
	lighttpdinstaller.install(letsencrypt: true)
	cmd := 'lego --email="${args.email}" --domains="${args.domain}" --http --accept-tos run'
}
