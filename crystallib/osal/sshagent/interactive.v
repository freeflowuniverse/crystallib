module sshagent

// import freeflowuniverse.crystallib.ui.console

// will see if there is one ssh key in sshagent
// or if not, if there is 1 ssh key in ${agent.homepath.path}/ if yes will load
// if we were able to define the key to use, it will be returned here
// will return the key which will be used
// pub fn load_interactive() ! {
// 	mut pubkeys := pubkeys_get()
// 	mut c := console.UIConsole{}
// 	pubkeys.map(listsplit)
// 	if pubkeys.len == 1 {
// 		c.ask_yesno(
// 			description: 'We found sshkey ${pubkeys[0]} in sshagent, want to use this one?'
// 		)!
// 		{
// 			key_load(pubkeys[0])!
// 			return pubkeys[0]
// 		}
// 	}
// 	if pubkeys.len > 1 {
// 		if c.ask_yesno(
// 			description: 'We found more than 1 sshkey in sshagent, want to use one of those!'
// 		)!
// 		{
// 			// keytouse := console.ask_dropdown(
// 			// 	items: pubkeys
// 			// 	description: 'Please choose the ssh key you want to use'
// 			// )
// 			// key_load(keytouse)!
// 			// return keytouse
// 		}
// 	}

// 	// now means nothing in ssh-agent, lets see if we find 1 key in .ssh directory
// 	mut sshdirpath := pathlib.get_dir(path: '${os.home_dir()}/.ssh', create: true)!

// 	mut pubkeys := []string{}
// 	pl := sshdirpath.list(recursive: false)!
// 	for p in pl.paths {
// 		if p.path.ends_with('.pub') {
// 			pubkeys << p.path.replace('.pub', '')
// 		}
// 	}
// 	// console.print_debug(keypaths)

// 	if pubkeys.len == 1 {
// 		if c.ask_yesno(
// 			description: 'We found sshkey ${pubkeys[0]} in ${agent.homepath.path} dir, want to use this one?'
// 		)!
// 		{
// 			key_load(pubkeys[0])!
// 			return pubkeys[0]
// 		}
// 	}
// 	if pubkeys.len > 1 {
// 		if c.ask_yesno(
// 			description: 'We found more than 1 sshkey in ${agent.homepath.path} dir, want to use one of those?'
// 		)!
// 		{
// 			// keytouse := console.ask_dropdown(
// 			// 	items: pubkeys
// 			// 	description: 'Please choose the ssh key you want to use'
// 			// )
// 			// key_load(keytouse)!
// 			// return keytouse
// 		}
// 	}

// will see if there is one ssh key in sshagent
// or if not, if there is 1 ssh key in ${agent.homepath.path}/ if yes will return
// if we were able to define the key to use, it will be returned here
// pub fn pubkey_guess() !string {
// 	pubkeys := pubkeys_get()
// 	if pubkeys.len == 1 {
// 		return pubkeys[0]
// 	}
// 	if pubkeys.len > 1 {
// 		return error('There is more than 1 ssh-key loaded in ssh-agent, cannot identify which one to use.')
// 	}
// 	// now means nothing in ssh-agent, lets see if we find 1 key in .ssh directory
// 	mut sshdirpath := pathlib.get_dir(path: '${os.home_dir()}/.ssh', create: true)!

// 	// todo: use ourregex field to nly list .pub files
// 	mut fl := sshdirpath.list()!
// 	mut sshfiles := fl.paths
// 	mut keypaths := sshfiles.filter(it.path.ends_with('.pub'))
// 	// console.print_debug(keypaths)

// 	if keypaths.len == 1 {
// 		keycontent := keypaths[0].read()!
// 		privkeypath := keypaths[0].path.replace('.pub', '')
// 		key_load(privkeypath)!
// 		return keycontent
// 	}
// 	if keypaths.len > 1 {
// 		return error('There is more than 1 ssh-key in your ${agent.homepath.path} dir, could not automatically load.')
// 	}
// 	return error('Could not find sshkey in your ssh-agent as well as in your ${agent.homepath.path} dir, please generate an ssh-key')
// }

// 	if c.ask_yesno(description: 'Would you like to generate a new key?') {
// 		// name := console.ask_question(question: 'name', minlen: 3)
// 		// passphrase := console.ask_question(question: 'passphrase', minlen: 5)

// 		// keytouse := key_generate(name, passphrase)!

// 		// if console.ask_yesno(description:"Please acknowledge you will remember your passphrase for ever (-: ?"){
// 		// 	key_load(keytouse)?
// 		// 	return keytouse
// 		// }else{
// 		// 	return error("Cannot continue, did not find sshkey to use")
// 		// }
// 		// key_load_with_passphrase(keytouse, passphrase)!
// 	}!
// 	return error('Cannot continue, did not find sshkey to use')

// 	// url_github_add := "https://library.threefold.me/info/publishtools/#/sshkey_github"

// 	// osal.execute_interactive("open $url_github_add")?

// 	// if console.ask_yesno(description:"Did you manage to add the github key to this repo ?"){
// 	// 	console.print_debug(" - CONGRATS: your sshkey is now loaded.")
// 	// }

// 	// return keytouse
// }
