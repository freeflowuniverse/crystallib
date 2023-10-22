module sshagent

import freeflowuniverse.crystallib.ui.console
import os
import freeflowuniverse.crystallib.core.pathlib
import crypto.sha256

fn listsplit(key string) string {
	if key.trim(' ') == '' {
		return ''
	}
	if key.contains(' ') {
		splitted := key.split(' ')
		return splitted[splitted.len].replace('.pub', '')
	}
	return key
}

// will see if there is one ssh key in sshagent
// or if not, if there is 1 ssh key in ~/.ssh/ if yes will load
// if we were able to define the key to use, it will be returned here
// will return the key which will be used
pub fn load_interactive() !string {
	mut pubkeys := pubkeys_get()
	mut c := console.UIConsole{}
	pubkeys.map(listsplit)
	if pubkeys.len == 1 {
		c.ask_yesno(
			description: 'We found sshkey ${pubkeys[0]} in sshagent, want to use this one?'
		)
		{
			key_load(pubkeys[0])!
			return pubkeys[0]
		}
	}
	if pubkeys.len > 1 {
		if c.ask_yesno(
			description: 'We found more than 1 sshkey in sshagent, want to use one of those!'
		)
		{
			// keytouse := console.ask_dropdown(
			// 	items: pubkeys
			// 	description: 'Please choose the ssh key you want to use'
			// )
			// key_load(keytouse)!
			// return keytouse
		}
	}

	// now means nothing in ssh-agent, lets see if we find 1 key in .ssh directory
	mut sshdirpath := pathlib.get_dir('${os.home_dir()}/.ssh', true)!

	pubkeys = []string{}
 	pl:=sshdirpath.file_list(recursive: false)!
	for p in pl.paths{
		if p.path.ends_with('.pub') {
			pubkeys << p.path.replace('.pub', '')
		}
	}
	// println(keypaths)

	if pubkeys.len == 1 {
		if c.ask_yesno(
			description: 'We found sshkey ${pubkeys[0]} in ~/.ssh dir, want to use this one?'
		)
		{
			key_load(pubkeys[0])!
			return pubkeys[0]
		}
	}
	if pubkeys.len > 1 {
		if c.ask_yesno(
			description: 'We found more than 1 sshkey in ~/.ssh dir, want to use one of those?'
		)
		{
			// keytouse := console.ask_dropdown(
			// 	items: pubkeys
			// 	description: 'Please choose the ssh key you want to use'
			// )
			// key_load(keytouse)!
			// return keytouse
		}
	}

	if c.ask_yesno(description: 'Would you like to generate a new key?') {
		// name := console.ask_question(question: 'name', minlen: 3)
		// passphrase := console.ask_question(question: 'passphrase', minlen: 5)

		// keytouse := key_generate(name, passphrase)!

		// if console.ask_yesno(description:"Please acknowledge you will remember your passphrase for ever (-: ?"){
		// 	key_load(keytouse)?
		// 	return keytouse
		// }else{
		// 	return error("Cannot continue, did not find sshkey to use")
		// }
		// key_load_with_passphrase(keytouse, passphrase)!
	}
	return error('Cannot continue, did not find sshkey to use')

	// url_github_add := "https://library.threefold.me/info/publishtools/#/sshkey_github"

	// osal.execute_interactive("open $url_github_add")?

	// if console.ask_yesno(description:"Did you manage to add the github key to this repo ?"){
	// 	println( " - CONGRATS: your sshkey is now loaded.")
	// }

	// return keytouse
}

// will see if there is one ssh key in sshagent
// or if not, if there is 1 ssh key in ~/.ssh/ if yes will return
// if we were able to define the key to use, it will be returned here
pub fn pubkey_guess() !string {
	pubkeys := pubkeys_get()
	if pubkeys.len == 1 {
		return pubkeys[0]
	}
	if pubkeys.len > 1 {
		return error('There is more than 1 ssh-key loaded in ssh-agent, cannot identify which one to use.')
	}
	// now means nothing in ssh-agent, lets see if we find 1 key in .ssh directory
	mut sshdirpath := pathlib.get_dir('${os.home_dir()}/.ssh', true)!

	// todo: use ourregex field to nly list .pub files
	mut fl:=sshdirpath.file_list(pathlib.ListArgs{})!
	mut sshfiles := fl.paths
	mut keypaths := sshfiles.filter(it.path.ends_with('.pub'))
	// println(keypaths)

	if keypaths.len == 1 {
		keycontent := keypaths[0].read()!
		privkeypath := keypaths[0].path.replace('.pub', '')
		key_load(privkeypath)!
		return keycontent
	}
	if keypaths.len > 1 {
		return error('There is more than 1 ssh-key in your ~/.ssh dir, could not automatically load.')
	}
	return error('Could not find sshkey in your ssh-agent as well as in your ~/.ssh dir, please generate an ssh-key')
}

// see which sshkeys are loaded in ssh-agent
// will ignore errors, if there is an error will just return empty list
pub fn pubkeys_get() []string {
	mut pubkeys := []string{}
	res := os.execute('ssh-add -L')
	if res.exit_code == 0 {
		for line in res.output.split('\n') {
			if line.trim(' ') == '' {
				continue
			}
			if line.contains('/.ssh/') {
				// this way we know its an ssh line
				pubkeys << line.trim(' ')
			}
		}
	}
	return pubkeys
}

// is the ssh-agent loaded?
pub fn loaded() bool {
	res := os.execute('ssh-add -l')
	if res.exit_code == 0 {
		return true
	} else {
		return false
	}
}

// returns path to sshkey
pub fn key_generate(name string, passphrase string) !string {
	dest := '${os.home_dir()}/.ssh/${name}'
	if os.exists(dest) {
		os.rm(dest)!
	}
	cmd := 'ssh-keygen -t ed25519 -f ${dest} -P ${passphrase} -q'
	// println(cmd)
	rc := os.execute(cmd)
	if !(rc.exit_code == 0) {
		return error('Could not generated sshkey,\n${rc}')
	}
	return '${os.home_dir()}/.ssh/${name}'
}

pub fn reset() ! {
	res := os.execute('ssh-add -D')
	if res.exit_code > 0 {
		return error('cannot reset sshkeys.')
	}
}

// load the key, they key is content, other keys will be unloaded
pub fn key_load_single(key string) ! {
	hash := sha256.hexhash(key)
	reset()!
	path := '~/.ssh/${hash}'
	if os.exists(path) {
		os.rm(path)!
	}
	os.write_file(path, key)!
	key_load(path)!
}

pub fn key_load(keypath string) ! {
	res := os.execute('ssh-add ${keypath}')
	if res.exit_code > 0 {
		return error('cannot add ssh-key with path ${keypath}')
	}
}

pub fn key_load_with_passphrase(keypath string, passphrase string) ! {
	res := os.execute('ssh-add ${keypath}')
	if res.exit_code > 0 {
		return error('cannot add key_load_with_passphrase with path ${keypath}')
	}
}

// pub fn ssh_agent_keys() []string{
// 	res := os. execute("ssh-add -l")
// 	if res.exit_code==0{
// 		println(res)
// 		panic("sA")
// 		return []string{}
// 	}else{
// 		println(res)
// 		panic("sB")		
// 		return []string{}
// 	}
// }

// check if key loaded
// return if key found, and how many ssh keys found in general
pub fn key_loaded(name string) (bool, int) {
	mut counter := 0
	mut exists := false
	res := os.execute('ssh-add -l')
	if res.exit_code == 0 {
		for line in res.output.split('\n') {
			if line.trim(' ') == '' {
				continue
			}
			counter++
			if line.contains('.ssh/${name} ') {
				// space at end is needed because then we know its not partial part of ssh key
				exists = true
			}
		}
	}
	return exists, counter
}
