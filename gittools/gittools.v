module gittools

import os

pub fn ssh_agent_loaded() bool {
	res := os. execute_or_panic('ssh-add -l') 
	if res.exit_code == 0 {
		return true
	} else {
		return false
	}
}

pub fn ssh_agent_reset() ? {
	_ := os. execute_or_panic('ssh-add -D')
}

pub fn ssh_agent_load(keypath string) ? {
	_ := os. execute_or_panic('ssh-add $keypath')
}

// pub fn ssh_agent_keys() []string{
// 	res := os. execute_or_panic("ssh-add -l") or {
// 			os.Result{exit_code:1,output:""}
// 		}
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
// return nr of keys found & if matched
pub fn ssh_agent_key_loaded(name string) (int, bool) {
	mut counter := 0
	mut exists := false
	res := os. execute_or_panic('ssh-add -l')
	if res.exit_code == 0 {
		for line in res.output.split('\n') {
			if line.trim(' ') == '' {
				continue
			}
			counter++
			if line.contains('.ssh/$name') {
				exists = true
			}
		}
	} else {
		return 0, false
	}
	return counter, exists
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
