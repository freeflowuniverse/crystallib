module process

import os

pub fn is_osx() bool {
	return os.uname().sysname.to_lower() == 'darwin'
}

pub fn is_osx_arm() bool {
	if is_osx() {
		return os.uname().machine.to_lower() == 'x86_64'
	}
	return false
}
