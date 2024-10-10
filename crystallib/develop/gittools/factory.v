module gittools

import freeflowuniverse.crystallib.core.base
import crypto.md5
import os
import json
import freeflowuniverse.crystallib.core.pathlib

__global (
	gsinstances shared map[string]&GitStructure
)

// Retrieve or create a new GitStructure instance with the given configuration.
pub fn getset(args_ GitStructureConfig) !&GitStructure {
	mut args := args_
	mut key := ''

	// Generate the coderoot and key.
	args.coderoot, key = gitstructure_key(args.coderoot)

	// Return existing instance if already created.
	if key in gsinstances {
		return get(coderoot: args.coderoot)!
	}

	// Store the configuration in Redis.
	datajson := json.encode(args)
	mut c := base.context()!
	mut redis := c.redis()!
	redis.set(gitstructure_config_key(key), datajson)!

	return get(GitStructureGetArgs{ coderoot: args_.coderoot })!
}

// Create a new GitStructure instance based on the provided arguments.
pub fn new(args_ GitStructureGetArgs) !&GitStructure {
	mut args := args_
	mut key := ''

	// Generate the coderoot and key.
	args.coderoot, key = gitstructure_key(args.coderoot)

	// Store the arguments in Redis.
	datajson := json.encode(args)
	mut c := base.context()!
	mut redis := c.redis()!
	redis.set(gitstructure_config_key(key), datajson)!

	return get(args_)
}

// Retrieve a GitStructure instance based on the given arguments.
pub fn get(args_ GitStructureGetArgs) !&GitStructure {
	mut args := args_
	mut key := ''

	// Generate the coderoot and key.
	args.coderoot, key = gitstructure_key(args.coderoot)
	rlock gsinstances {
		if key in gsinstances {
			mut gs := gsinstances[key] or {
				panic('Unexpected error: key not found in gsinstances')
			}
			if args.reload {
				gs.load()!
			}
			return gs
		}
	}

	// Retrieve the configuration from Redis.
	mut c := base.context()!
	mut redis := c.redis()!
	mut datajson := redis.get(gitstructure_config_key(key))!

	if datajson == '' {
		return error("Unable to find git structure for coderoot: '${args.coderoot}'")
	}

	mut config := json.decode(GitStructureConfig, datajson)!

	// Create and load the GitStructure instance.
	mut gs := &GitStructure{
		key:      key
		config:   config
		coderoot: pathlib.get_dir(path: args.coderoot, create: true)!
	}
	gs.load()!

	lock gsinstances {
		gsinstances[gs.key] = gs
	}

	return gs
}

// Reset the configuration cache for Git structures.
pub fn configreset() ! {
	mut c := base.context()!
	mut redis := c.redis()!
	key_check := 'git:config:*'
	keys := redis.keys(key_check)!

	for key in keys {
		redis.del(key)!
	}
}

// Reset all caches and configurations for all Git repositories.
pub fn cachereset() ! {
	key_check := 'git:repos:**'
	mut c := base.context()!
	mut redis := c.redis()!
	keys := redis.keys(key_check)!

	for key in keys {
		redis.del(key)!
	}
	configreset()!
}

// Generate the Redis key for the given coderoot.
fn gitstructure_config_key(coderoothashed string) string {
	return 'git:config:${coderoothashed}'
}

// Return the coderoot and its corresponding key.
fn gitstructure_key(coderoot_ string) (string, string) {
	mut coderoot := coderoot_
	mut key := 'default'

	if coderoot == '' {
		coderoot = '${os.home_dir()}/code'
	} else {
		key = md5.hexhash(coderoot)
	}
	return coderoot, key
}
