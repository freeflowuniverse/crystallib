module osal

import os
import freeflowuniverse.crystallib.core.pathlib

pub struct CmdAddArgs {
pub mut:
	cmdname string
	source  string @[required] // path where the binary is
	symlink bool // if rather than copy do a symlink
	reset   bool // if existing cmd will delete
	// bin_repo_url string = 'https://github.com/freeflowuniverse/freeflow_binary' // binary where we put the results
}

// copy a binary to the right location on the local computer .
// e.g. is /usr/local/bin on linux .
// e.g. is ~/hero/bin on osx .
// will also add the bin location to the path of .zprofile and .zshrc (different per platform)
pub fn cmd_add(args_ CmdAddArgs) ! {
	mut args := args_
	if args.cmdname == '' {
		args.cmdname = os.base(args.source)
	}
	mut dest := bin_path()!

	mut sourcepath := pathlib.get_file(path: args.source, create: false)!
	mut destpath := '${dest}/${args.cmdname}'

	// check if there is other file
	res := os.execute('which ${args.cmdname}')
	if res.exit_code == 0 {
		existing_path := res.output.trim_space()
		if destpath != existing_path {
			println(' - did find a cmd which is not in path we expect:\n    expected:${destpath}\n    got:${existing_path}')
			if args.reset {
				os.rm(existing_path)!
			} else {
				return error("existing cmd found on: ${existing_path} and can't delete.\nWas trying to install on ${destpath}.")
			}
		}
	}

	if args.symlink {
		sourcepath.link(destpath, true)!
	} else {
		sourcepath.copy(dest: destpath, rsync: false)!
	}

	mut destfile := pathlib.get_file(path: destpath, create: false)!

	destfile.chmod(0o770)! // includes read & write & execute

	// lets make sure this path is in profile
	profile_path_add(path: dest)!
}

pub fn profile_path_add_hero() !string {
	mut dest := bin_path()!
	profile_path_add(path: dest)!
	return dest
}

@[params]
pub struct ProfilePathAddArgs {
pub mut:
	path     string @[required]
	todelete string // see which one to remove
}

// add the following path to a profile
pub fn profile_path_add(args ProfilePathAddArgs) ! {
	mut toadd := []string{}
	path := args.path
	if is_osx() {
		toadd << '${os.home_dir()}/.zprofile'
		toadd << '${os.home_dir()}/.zshrc'
	} else {
		toadd << '${os.home_dir()}/.bash_profile'
		toadd << '${os.home_dir()}/.bashrc'
	}

	for profile_path in toadd {
		profile_path_add_(profile_path, path, args.todelete)!
	}
}

pub fn profile_path() string {
	if is_osx() {
		return '${os.home_dir()}/.zprofile'
	} else {
		return '${os.home_dir()}/.bash_profile'
	}
}

pub fn bin_path() !string {
	mut dest := ''
	if is_osx() {
		dest = '${os.home_dir()}/hero/bin'
		dir_ensure(dest)!
	} else {
		dest = '/usr/local/bin'
	}
	return dest
}

pub fn hero_path() !string {
	mut dest := ''
	dest = '${os.home_dir()}/hero'
	dir_ensure(dest)!
	return dest
}

///usr/local on linux, ${os.home_dir()}/hero on osx
pub fn usr_local_path() !string {
	mut dest := ''
	if is_osx() {
		dest = '${os.home_dir()}/hero'
		dir_ensure(dest)!
	} else {
		dest = '/usr/local'
	}
	return dest
}

// return the source statement if the profile exists
pub fn profile_path_source() string {
	if hostname() or { '' } == 'rescue' {
		return ''
	}
	pp := profile_path()
	if os.exists(pp) {
		return 'source ${pp}'
	}
	return ''
}

// return source $path &&  .
// or empty if it doesn't exist
pub fn profile_path_source_and() string {
	if hostname() or { '' } == 'rescue' {
		return ''
	}
	pp := profile_path()
	if os.exists(pp) {
		return '. ${pp} &&'
	}
	return ''
}

fn profile_paths_get(content string) []string {
	mut paths := []string{}
	for line in content.split_into_lines() {
		if line.contains('PATH') {
			post := line.all_after_last('=').trim('\'" ,')
			splitted := post.split(':')
			for item in splitted {
				item2 := item.trim(' "\'')
				if item2 !in paths && !item2.contains('PATH') {
					paths << item2
				}
			}
		}
	}
	return paths
}

fn profile_path_add_(profile_path_ string, path2add string, todelete string) ! {
	// println(" -- profile path add: ${profile_path_} : ${path2add} : $todelete")
	mut profile_path := pathlib.get_file(path: profile_path_, create: true)!
	mut c := profile_path.read()!

	if todelete.len > 0 {
		c = c.split_into_lines().filter(!it.contains(todelete)).join_lines()
	}

	paths := profile_paths_get(c)
	if path2add in paths {
		return
	}
	c += '\nexport PATH=\$PATH:${path2add}\n'
	profile_path.write(c)!
	// println(c)
}
