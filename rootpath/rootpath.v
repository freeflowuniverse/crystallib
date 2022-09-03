module rootpath

import os

// replace ~ to home dir in string as given
pub fn shell_expansion(s string) string {
	if s.contains('~') {
		home := os.real_path(os.home_dir())
		return s.replace('~', home)
	}

	return s
}

// root dir for our hub3 environment
pub fn rootdir() string {
	return shell_expansion('~/.hub3')
}

// bin dir
pub fn bindir() string {
	return path_ensure('$rootdir()/bin')
}

// var dir
pub fn vardir() string {
	return path_ensure('$rootdir()/var')
}

// cfg dir
pub fn cfgdir() string {
	return path_ensure('$rootdir()/cfg')
}

// return path and ensure it exists and return the path
pub fn path_ensure(s string) string {
	s1 := s.trim_left(' /')
	s2 := '$rootdir()/$s1/'
	if !os.exists(s2) {
		os.mkdir_all(s2) or { panic('cannot create dir $s2') }
	}
	return s2
}

// get path underneith the root
pub fn path(s string) string {
	s1 := s.trim_left(' /')
	s2 := '$rootdir()/$s1/'
	return s2
}
