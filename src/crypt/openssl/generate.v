module openssl

import freeflowuniverse.crystallib.builder
import json

[params]
pub struct OpenSSLGenerateArgs {
	name   string = 'default'
	domain string = 'myregistry.domain.com'
	reset  bool
}

pub fn (mut ossl OpenSSL) generate(args OpenSSLGenerateArgs) !OpenSSLKey {
	mut r := ossl.new(args)!

	if r.domain.len < 6 {
		return error('need to give domain and needs to be bigger than 6 chars. \n${r}')
	}

	cmd := '
	openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${r.path_key.path} -addext "subjectAltName = DNS:${args.domain}" -subj "/C=BE/ST=Ghent/L=Something/O=Global Security/OU=IT Department/CN=${args.domain}" -x509 -days 365 -out ${r.path_cert.path}
	'

	mut b := builder.new()!
	mut node := b.node_local()!

	node.exec(cmd)!

	r.hexhash()!

	s := json.encode(r)

	r.path_json.write(s)!

	return r
}
