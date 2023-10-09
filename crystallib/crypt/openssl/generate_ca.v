module openssl

import freeflowuniverse.crystallib.builder
import json

[params]
pub struct OpenSSLCAGenerateArgs {
	name   string = 'default'
	domain string = 'myregistry.domain.com'
	reset  bool
}

pub fn (mut ossl OpenSSL) generate_ca(args OpenSSLGenerateArgs) !OpenSSLKey {
	mut r := ossl.new(args)!

	if r.domain.len < 6 {
		return error('need to give domain and needs to be bigger than 6 chars. \n${r}')
	}

	mut b := builder.new()!
	mut node := b.node_local()!

	// info on https://mariadb.com/docs/xpand/security/data-in-transit-encryption/create-self-signed-certificates-keys-openssl/

	cmd := '



	openssl genrsa 2048 > ca-key.pem

	#Creating the Certificate Authoritys Certificate and Keys
	openssl req -new -x509 -nodes -days 365000 -key ca-key.pem -out ca-cert.pem -subj "/C=BE/ST=Ghent/L=Something/O=Global Security/OU=IT Department/CN=${args.domain}"

	openssl req -newkey rsa:2048 -nodes -days 365000 -keyout server-key.pem -out server-req.pem		

	openssl x509 -req -days 365000 -set_serial 01 -in server-req.pem -out server-cert.pem -CA ca-cert.pem -CAkey ca-key.pem		

	rm -rf /tmp/w
	mkdir -p /tmp/w
	cd /tmp/w

	openssl genrsa 2048 > ca-key.pem

	#Creating the Certificate Authoritys Certificate and Keys
	openssl req -new -x509 -nodes -days 365000 -key ca-key.pem -out ca-cert.pem -subj "/C=BE/ST=Ghent/L=Something/O=Global Security/OU=IT Department/CN=registry.test.com"

	openssl req -newkey rsa:2048 -nodes -days 365000 -keyout server-key.pem -out server-req.pem	-subj "/C=BE/ST=Ghent/L=Something/O=Global Security/OU=IT Department/CN=registry.test.com"

	openssl x509 -req -days 365000 -set_serial 01 -in server-req.pem -out server-cert.pem -CA ca-cert.pem -CAkey ca-key.pem		


	'

	node.exec(cmd)!

	cmd2 := '
	openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${r.path_key.path} -addext "subjectAltName = DNS:${args.domain}" -subj "/C=BE/ST=Ghent/L=Something/O=Global Security/OU=IT Department/CN=${args.domain}" -x509 -days 365 -out ${r.path_cert.path}
	'

	node.exec(cmd2)!

	r.hexhash()!

	s := json.encode(r)

	r.path_json.write(s)!

	return r
}
