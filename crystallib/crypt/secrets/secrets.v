module secrets

import freeflowuniverse.crystallib.clients.redisclient
import rand
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.crypt.aes_symmetric
import crypto.md5
import regex
import os
import encoding.base64

pub struct SecretBox {
pub mut:
	secret string
}

@[params]
pub struct SecretBoxArgs {
pub mut:
	reset       bool
	interactive bool = true
}

// will use our secret as configured for the hero to encrypt
pub fn encrypt(txt string) !string {
	mut b := get()!
	d := aes_symmetric.encrypt_str(txt, b.secret)
	return base64.encode_str(d)
}

pub fn decrypt(txt string) !string {
	mut b := get()!
	txt2 := base64.decode_str(txt)
	return aes_symmetric.decrypt_str(txt2, b.secret)
}

// make sure that the default passphrase  or passwd is gone
pub fn delete_passwd() ! {
	mut b := get()!
	mut r := redisclient.core_get()!
	key := 'secretbox:main'
	r.del(key)!
}

pub fn get(args SecretBoxArgs) !SecretBox {
	if args.reset {
		reset()!
	}
	mut r := redisclient.core_get()!
	if args.interactive == false {
		return error("can't use secretbox in non-interactive mode")
	}
	key := 'secretbox:main'
	mut secret := r.get(key)!
	if secret.len == 0 {
		mut myui := ui.new()!
		console.clear()
		secret_ := myui.ask_question(question: 'Please enter your hero secret string:')!
		secret = md5.hexhash(secret_)
		r.set(key, secret)!
	}
	return SecretBox{
		secret: secret
	}
}

pub fn reset() ! {
	mut r := redisclient.core_get()!
	mut keys := r.keys('secretbox:keys:*')!
	for key in keys {
		r.del(key)!
	}
}

@[params]
pub struct SecretArgs {
pub mut:
	key       string     @[required]
	default   string // if it doesn't exist yet, will create it with this value
	overwrite string // will overwrite the secret with this value even if it exists
	cat       SecretType
	reset     bool
}

pub enum SecretType {
	normal
	openssl_hex
	openssl_base64
}

pub fn hex_secret() !string {
	return rand.hex(24)
}

pub fn openssl_hex_secret() !string {
	cmd := 'openssl rand -hex 32'
	result := os.execute(cmd)
	if result.exit_code > 0 {
		return error('Command failed with exit code: ${result.exit_code} and error: ${result.output}')
	}
	return result.output.trim_space()
}

pub fn openssl_base64_secret() !string {
	cmd := 'openssl rand -base64 32'
	result := os.execute(cmd)
	if result.exit_code > 0 {
		return error('Command failed with exit code: ${result.exit_code} and error: ${result.output}')
	}
	return result.output.trim_space()
}

// creates a secret if it doesn exist yet
pub fn (mut sm SecretBox) secret(args_ SecretArgs) !string {
	mut args := args_
	args.key = args.key.replace('.', ':').trim(':') // make sure we remove at start and end
	mut r := redisclient.core_get()!
	key := 'secretbox:keys:${args.key}'.to_lower()
	if args.reset || args.overwrite.len > 0 {
		r.del(key)!
		if args.overwrite.len > 0 {
			args.default = args.overwrite
		}
	}
	mut secret_ := r.get(key)!
	mut secret := ''
	if secret_.len == 0 {
		if args.default.len > 0 {
			secret = args.default
		} else {
			match args.cat {
				.normal {
					secret = rand.hex(24)
				}
				.openssl_hex {
					secret = openssl_hex_secret()!
				}
				.openssl_base64 {
					secret = openssl_base64_secret()!
				}
			}
		}
		secret_ = aes_symmetric.encrypt_str(secret, sm.secret)
		r.set(key, secret_)!
	} else {
		secret = aes_symmetric.decrypt_str(secret_, sm.secret)
	}
	return secret
}

pub fn (mut sm SecretBox) exists(name_ string) !bool {
	name := name_.replace('.', ':').trim(':') // make sure we remove at start and end
	mut r := redisclient.core_get()!
	key := 'secretbox:keys:${name}'.to_lower()
	mut secret_ := r.get(key)!
	if secret_.len == 0 {
		return false
	}
	return true
}

pub fn (mut sm SecretBox) delete(name_ string) !bool {
	name := name_.replace('.', ':').trim(':') // make sure we remove at start and end
	mut r := redisclient.core_get()!
	key := 'secretbox:keys:${name}'.to_lower().trim(':') + '*'
	// println(" --- delete: ${key}")
	mut keys := r.keys(key)!
	for key2 in keys {
		// println(" --- delete: ${key2}")
		r.del(key2)!
	}
	return true
}

pub fn (mut sm SecretBox) get(name_ string) !string {
	name := name_.replace('.', ':').trim(':') // make sure we remove at start and end
	mut r := redisclient.core_get()!
	key := 'secretbox:keys:${name}'.to_lower()
	mut secret_ := r.get(key)!
	mut secret := ''
	if secret_.len == 0 {
		return error("Can't find key with name '${name_}' in secret box")
	} else {
		secret = aes_symmetric.decrypt_str(secret_, sm.secret)
	}
	return secret
}

pub struct DefaultSecretArgs {
pub:
	secret string
	cat    SecretType
}

@[params]
pub struct ReplaceArgs {
pub mut:
	txt          string                       @[required]
	defaults     map[string]DefaultSecretArgs // will overwrite
	printsecrets bool
}

// find all {AABB} (all capital letters), check as lower case if found in the secrets, if yes will replace
pub fn (mut sm SecretBox) replace(args_ ReplaceArgs) !string {
	mut args := args_
	mut re := regex.regex_opt(r'\{[A-Z0-9.]+\}') or { panic(err) }
	matches := re.find_all_str(args.txt)

	for key, value in args_.defaults {
		new_key := key.to_lower()
		args.defaults[new_key] = value
	}

	for m in matches {
		m2 := m.to_lower().trim('{}')
		// println("Found match: ${m2}")
		vexists := sm.exists(m2)!
		if vexists || m2 in args.defaults {
			// println("Found secret for ${m2}")
			mut mysecret := ''
			if m2 in args.defaults && args.defaults[m2].secret.len > 0 {
				// println("Overwriting secret with default")
				mysecret = sm.secret(
					key: m2
					overwrite: args.defaults[m2].secret
					cat: args.defaults[m2].cat
				)!
			} else {
				mysecret = sm.secret(key: m2, cat: args.defaults[m2].cat)!
			}
			if args.printsecrets {
				console.print_header(' - secret ${m2} is ${mysecret}')
			}
			args.txt = args.txt.replace(m, mysecret)
		}
	}

	return args.txt
}
