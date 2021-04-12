module gittools

import os

pub fn ssh_agent_loaded() bool {
	res := os.execute('ssh-add -l')
	if res.exit_code == 0 {
		return true
	} else {
		return false
	}
}

pub fn ssh_agent_reset() ? {
	_ := os.execute('ssh-add -D')
}

pub fn ssh_agent_load(keypath string) ? {
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
pub fn ssh_agent_key_loaded(name string) (bool, int) {
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

// the factory for getting the gitstructure
// git is checked uderneith $/code
pub fn new(root string) ?GitStructure {
	mut gitstructure := GitStructure{
		root: root
	}
	gitstructure.load() ?
	return gitstructure
}
