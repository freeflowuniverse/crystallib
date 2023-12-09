module sshagent

pub struct SSHKey {
pub mut:
	path   string
	pubkey string
	loaded bool
	email  string
}

// [params]
// pub struct KeyExistsArgs{
// 	pubkey string
// 	privkey string
// 	pubkey_path string
// 	privkey_path string
// 	name string
// }

// pub fn key_exists(args) KeyExistsArgs) bool {
// 	pubkeys:=pubkeys_get()
// 	return pubkey in pubkeys
// }
