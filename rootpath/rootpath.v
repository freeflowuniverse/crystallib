module rootpath

import os

pub fn shell_expansion(s string) string {
	if s.contains("~") {
		home := os.real_path(os.home_dir())
		return s.replace("~", home)
	}

	return s
}

pub fn default_path() string {
	return shell_expansion("~/.hub3")
}

pub fn default_prefix(s string) string {
	return default_path() + s
}
