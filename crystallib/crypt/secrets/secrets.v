module secrets

import rand
import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.crypt.aes_symmetric
import crypto.md5
import regex
import os
import encoding.base64

@[params]
pub struct SecretArgs {
pub mut:
	key       string     @[required]
	default   string // if it doesn't exist yet, will create it with this value
	overwrite string // will overwrite the secret with this value even if it exists
	cat       SecretType
	// reset     bool
}

pub enum SecretType {
	normal
	openssl_hex
	openssl_base64
}

// // creates a secret if it doesn exist yet
// pub fn (mut b SecretBox) secret_add(args_ SecretArgs) !string {
// 	mut args := args_
// 	args.key = args.key.replace('.', ':').trim(':').to_lower()
// 	mut secret_ := b.items[args.key] or {""}
// 	mut secret := ''
// 	if secret_.len == 0 {
// 		if args.default.len > 0 {
// 			secret = args.default
// 		} else {
// 			match args.cat {
// 				.normal {
// 					secret = rand.hex(24)
// 				}
// 				.openssl_hex {
// 					secret = openssl_hex_secret()!
// 				}
// 				.openssl_base64 {
// 					secret = openssl_base64_secret()!
// 				}
// 			}
// 		}
// 		secret_ = aes_symmetric.encrypt_str(secret, b.secret)		
// 	} else {
// 		secret = aes_symmetric.decrypt_str(secret_, b.secret)
// 	}
// 	b.items[args.key] = secret
// 	return secret
// }

// pub fn (mut b SecretBox) secret_exists(name_ string) !bool {
// 	name := name_.replace('.', ':').trim(':').to_lower()
// 	mut secret_ := b.items[name] or {""}
// 	if secret_.len == 0 {
// 		return false
// 	}
// 	return true
// }

// pub fn (mut b SecretBox) secret_delete(name_ string) {
// 	name := name_.replace('.', ':').trim(':').to_lower()
// 	if name in b.items{
// 		b.items.delete(name)
// 	}
// }

// TODO: need to re-implement

// pub fn (mut sm SecretBox) secret_get(name_ string) !string {
// 	name := name_.replace('.', ':').trim(':') // make sure we remove at start and end
// 	mut c:=base.context()!
// mut r:=c.redis()!
// 	key := 'secretbox:keys:${name}'.to_lower()
// 	mut secret_ := r.get(key)!
// 	mut secret := ''
// 	if secret_.len == 0 {
// 		return error("Can't find key with name '${name_}' in secret box")
// 	} else {
// 		secret = aes_symmetric.decrypt_str(secret_, sm.secret)
// 	}
// 	return secret
// }

// pub struct DefaultSecretArgs {
// pub:
// 	secret string
// 	cat    SecretType
// }

// @[params]
// pub struct ReplaceArgs {
// pub mut:
// 	txt          string                       @[required]
// 	defaults     map[string]DefaultSecretArgs // will overwrite
// 	printsecrets bool
// }

// // find all {AABB} (all capital letters), check as lower case if found in the secrets, if yes will replace
// pub fn (mut sm SecretBox) replace(args_ ReplaceArgs) !string {
// 	mut args := args_
// 	mut re := regex.regex_opt(r'\{[A-Z0-9.]+\}') or { panic(err) }
// 	matches := re.find_all_str(args.txt)

// 	for key, value in args_.defaults {
// 		new_key := key.to_lower()
// 		args.defaults[new_key] = value
// 	}

// 	for m in matches {
// 		m2 := m.to_lower().trim('{}')
// 		// console.print_debug("Found match: ${m2}")
// 		vexists := sm.exists(m2)!
// 		if vexists || m2 in args.defaults {
// 			// console.print_debug("Found secret for ${m2}")
// 			mut mysecret := ''
// 			if m2 in args.defaults && args.defaults[m2].secret.len > 0 {
// 				// console.print_debug("Overwriting secret with default")
// 				mysecret = sm.secret(
// 					key: m2
// 					overwrite: args.defaults[m2].secret
// 					cat: args.defaults[m2].cat
// 				)!
// 			} else {
// 				mysecret = sm.secret(key: m2, cat: args.defaults[m2].cat)!
// 			}
// 			if args.printsecrets {
// 				console.print_header(' - secret ${m2} is ${mysecret}')
// 			}
// 			args.txt = args.txt.replace(m, mysecret)
// 		}
// 	}

// 	return args.txt
// }

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
