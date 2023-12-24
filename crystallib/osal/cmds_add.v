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
	mut dest := ''
	if is_osx() {
		dest = '${os.home_dir()}/hero/bin'
		dir_ensure(dest)!
	} else {
		dest = '/usr/local/bin'
	}

	mut sourcepath := pathlib.get_file(path: args.source, create: false)!
	mut destpath := '${dest}/${args.cmdname}'

	// check if there is other file
	res := os.execute('which ${args.cmdname}')
	if res.exit_code == 0 {
		existing_path := res.output.trim_space()
		if dest != existing_path {
			if args.reset {
				os.rm(existing_path)!
			} else {
				return error("existing cmd found on: ${existing_path} and can't delete.")
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
	profile_path_add(dest)!
}

pub fn profile_path_add_hero() !string {
	mut dest := ''
	if is_osx() {
		dest = '${os.home_dir()}/hero/bin'
		dir_ensure(dest)!
	} else {
		dest = '/usr/local/bin'
	}
	profile_path_add(dest)!
	return dest
}

// add the following path to a profile
pub fn profile_path_add(path string) ! {
	mut toadd := []string{}
	if is_osx() {
		toadd << '${os.home_dir()}/.zprofile'
		toadd << '${os.home_dir()}/.zshrc'
	} else {
		toadd << '${os.home_dir()}/.bash_profile'
		toadd << '${os.home_dir()}/.bashrc'
	}

	for profile_path in toadd {
		profile_path_add_(profile_path, path)!
	}
}

pub fn profile_path() string {
	if is_osx() {
		return '${os.home_dir()}/.zprofile'
	} else {
		return '${os.home_dir()}/.bash_profile'
	}
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

fn profile_path_add_(profile_path_ string, path2add string) ! {
	// println(" -- profile path process: ${profile_path_}")
	mut profile_path := pathlib.get_file(path: profile_path_, create: true)!
	mut c := profile_path.read()!

	paths := profile_paths_get(c)
	if path2add in paths {
		return
	}
	c += '\nexport PATH=\$PATH:${path2add}\n'
	profile_path.write(c)!
}
