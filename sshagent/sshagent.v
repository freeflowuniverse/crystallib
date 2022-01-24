module sshagent

import os
import path


//will see if there is one ssh key in sshagent
// or if not, if there is 1 ssh key in ~/.ssh/ if yes will load
// if we were able to define the key to use, it will be returned here
pub fn pubkey_guess() ?string {

	pubkeys := pubkeys_get()
	if pubkeys.len == 1{
		return pubkeys[0]
	}
	if pubkeys.len > 1{
		return error("There is more than 1 ssh-key loaded in ssh-agent, cannot identify which one to use.")
	}
	//now means nothing in ssh-agent, lets see if we find 1 key in .ssh directory
	mut sshdirpath := path.get_dir('$os.home_dir()/.ssh',true)?

	mut keypaths := sshdirpath.file_list(".pub",false)?
	println(keypaths)

	if keypaths.len==1{
		keycontent := keypaths[0].read()?
		return keycontent
	}
	if keypaths.len>1{
		return error("There is more than 1 ssh-key in your ~/.ssh dir, could not automatically load.")
	}
	return error("Could not find sshkey in your ssh-agent as well as in your ~/.ssh dir, please generate an ssh-key")
}

//see which sshkeys are loaded in ssh-agent
pub fn pubkeys_get() []string {
	mut pubkeys := []string{}
	res := os.execute('ssh-add -L')
	if res.exit_code == 0 {
		for line in res.output.split('\n') {
			if line.trim(' ') == '' {
				continue
			}
			if line.contains('/.ssh/') {
				//this way we know its an ssh line
				pubkeys << line.trim(" ")
			}
		}
	}
	return pubkeys	
}

//is the ssh-agent loaded?
pub fn loaded() bool {
	res := os.execute('ssh-add -l')
	if res.exit_code == 0 {
		return true
	} else {
		return false
	}
}

pub fn reset() ? {
	_ := os.execute('ssh-add -D')
}

pub fn key_load(keypath string) ? {
	_ := os.execute('ssh-add $keypath')
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
			if line.contains('.ssh/$name ') {
				// space at end is needed because then we know its not partial part of ssh key
				exists = true
			}
		}
	}
	return exists, counter
}
