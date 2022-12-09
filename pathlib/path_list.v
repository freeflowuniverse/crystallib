module pathlib

import os
import regex {RE}
pub struct EmptyRegex {

}

type OurRegex = RE | EmptyRegex

pub struct ListArgs {
pub mut:
	regex	  OurRegex
	recursive bool   // std off, means we recursive not over dirs by default
	ignoredefault bool=true //ignore files starting with . and _
}

// list all files & dirs, follow symlinks
// will sort all items
// return as list of Paths
// param tofind: part of name (relative to string)
// param recursive: if recursive behaviour
pub fn (mut path Path) list(mut args ListArgs) ![]Path {
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
				mut rec_list := new_path.list(mut args)!
				all_list << rec_list
			}
		}
		// Check if tofound is a part of the path
		mut r:=args.regex
		mut continuebool := false
		if r is RE{
			// println(r)
			// panic("s")
			// continuebool = r.matches_string(item) //returns true if it matches
		}
		if args.ignoredefault{
			if item.starts_with("_") ||  item.starts_with(".") {
				continuebool = true
			}
		}
		if continuebool {
			continue
		}
		all_list << new_path
	}
	return all_list
}

// find dir underneith path,
pub fn (mut path Path) dir_list(mut args ListArgs) ![]Path {
	list_all := path.list(mut args)!
	mut list_dirs := list_all.filter(it.cat == Category.dir)
	return list_dirs
}

// find file underneith path,
pub fn (mut path Path) file_list(mut args ListArgs) ![]Path {
	list_all := path.list(mut args)!
	mut list_files := list_all.filter(it.cat == Category.file)
	return list_files
}

// find links (don't follow)
pub fn (mut path Path) link_list(mut args ListArgs) ![]Path {
	list_all := path.list(mut args)!
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
