module osal

import freeflowuniverse.crystallib.core.pathlib
import os

@[params]
pub struct EnvSet {
pub mut:
	key       string @[required]
	value     string @[required]
	overwrite bool = true
}

@[params]
pub struct EnvSetAll {
pub mut:
	env                 map[string]string
	clear_before_set    bool
	overwrite_if_exists bool = true
}

// Sets an environment if it was not set before, it overwrites the enviroment variable if it exists and if overwrite was set to true (default)
pub fn env_set(args EnvSet) {
	os.setenv(args.key, args.value, args.overwrite)
}

// Unsets an environment variable
pub fn env_unset(key string) {
	os.unsetenv(key)
}

// Unsets all environment variables
pub fn env_unset_all() {
	for key, _ in os.environ() {
		env_unset(key)
	}
}

// Allows to set multiple enviroment variables in one go, if clear_before_set is true all existing environment variables will be unset before the operation, if overwrite_if_exists is set to true it will overwrite all existing enviromnent variables
pub fn env_set_all(args EnvSetAll) {
	if args.clear_before_set {
		env_unset_all()
	}
	for key, val in args.env {
		env_set(key: key, value: val, overwrite: args.overwrite_if_exists)
	}
}

// Returns all existing environment variables
pub fn env_get_all() map[string]string {
	return os.environ()
}

// Returns the requested environment variable if it exists or throws an error if it does not
pub fn env_get(key string) !string {
	return os.environ()[key]!
}

// Returns the requested environment variable if it exists or returns the provided default value if it does not
pub fn env_get_default(key string, def string) string {
	return os.environ()[key] or { return def }
}

pub fn load_env_file(file_path string) ! {
	mut file := pathlib.get_file(path: file_path)!
	content := file.read()!
	lines := content.split_into_lines()
	for line in lines {
		if line.len == 0 || line[0] == `#` {
			continue
		}
		if !line.contains('=') {
			continue
		}
		parts := line.split('=')
		key := line.all_before('=').trim_space()
		value := line.all_after('=').trim_space()
		os.setenv(key, value, true)
	}
}
