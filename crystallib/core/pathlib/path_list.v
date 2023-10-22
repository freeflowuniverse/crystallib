module pathlib

import os
import regex

[params]
pub struct ListArgs {
pub mut:
	regex         []string
	recursive     bool = true 
	ignoredefault bool = true // ignore files starting with . and _
}

// list all files & dirs, follow symlinks .
// will sort all items .
// return as list of Paths .
// .
// params: .
// ```golang
// regex         []regex.RE
// recursive     bool // std off, means we recursive not over dirs by default
// ignoredefault bool = true // ignore files starting with . and _
// ```
//
pub fn (path Path) list(args_ ListArgs) ![]Path {
	mut r:=[]regex.RE{}
	for regexstr in args_.regex{
		mut re := regex.regex_opt(regexstr) or { return error("cannot create regex for:'${regexstr}'") }
		println(re.get_query())		
		r << re
	}
	mut args:=ListArgsInternal{
		regex:r
		recursive:args_.recursive
		ignoredefault:args_.ignoredefault
	}
	return path.list_internal(args)!
}

[params]
pub struct ListArgsInternal {
mut:
	regex         []regex.RE
	recursive     bool = true 
	ignoredefault bool = true // ignore files starting with . and _
}

fn (path Path) list_internal(args ListArgsInternal) ![]Path {
	if path.cat !in [Category.dir, Category.linkdir] {
		return error('Path must be directory or link to directory')
	}
	mut ls_result := os.ls(path.path) or { []string{} }
	ls_result.sort()
	mut all_list := []Path{}
	for item in ls_result {
		p := os.join_path(path.path, item)
		mut new_path := get(p)
		// Check for dir and linkdir
		if !new_path.exists() {
			// to deal with broken link
			continue
		}
		if new_path.is_dir() {
			// If recusrive
			if args.recursive {
				mut rec_list := new_path.list_internal(args)!
				all_list << rec_list
			}
		}
		mut addthefile := true
		for r in args.regex{
			if !(r.matches_string(item)){
				addthefile=false
			}
		}
		if args.ignoredefault {
			if item.starts_with('_') || item.starts_with('.') {
				addthefile=false
			}
		}
		if addthefile {
			all_list << new_path
		}	
	}
	return all_list
}

// find dir underneith path,
pub fn (path Path) dir_list(args ListArgs) ![]Path {
	list_all := path.list(args)!
	mut list_dirs := list_all.filter(it.cat == Category.dir)
	return list_dirs
}

// find file underneith path,
pub fn (path Path) file_list(args ListArgs) ![]Path {
	list_all := path.list(args)!
	mut list_files := list_all.filter(it.cat == Category.file)
	return list_files
}

// find links (don't follow)
pub fn (mut path Path) link_list(args ListArgs) ![]Path {
	list_all := path.list(args)!
	mut list_links := list_all.filter(it.cat in [Category.linkdir, Category.linkfile])
	return list_links
}

// struct PathList {
// 	// is the root under which all paths are, think about it like a changeroot environment
// 	root  string
// 	paths []Path
// mut:
// 	exists i8
// }

// // copy all
// // pub fn (mut pathlist PathList) copy(dest Path)!Path{
// // }

// // //delete all
// // pub fn (mut pathlist PathList) delete(dest Path)!Path{
// // }

// // //return relative path of path in relation to root in PathList
// // pub fn (mut pathlist PathList) path_relative()!_get(path Path)!string{
// // }

// // pub fn (mut pathlist PathList) path_abs_get(path Path)!string{
// // }

// // pub fn (mut pathlist PathList) add(path Path){
// // }
