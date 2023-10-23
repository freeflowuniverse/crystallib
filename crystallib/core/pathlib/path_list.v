module pathlib

import os
import regex
import freeflowuniverse.crystallib.baobab.smartid

[params]
pub struct ListArgs {
pub mut:
	regex         []string
	recursive     bool = true
	ignoredefault bool = true // ignore files starting with . and _
}

// the result of pathlist
pub struct PathList {
pub mut:
	// is the root under which all paths are, think about it like a changeroot environment
	root  string
	paths []Path
}

// list all files & dirs, follow symlinks .
// will sort all items .
// return as list of Paths .
// .
// params: .
// ```golang
// regex         []string
// recursive     bool // std off, means we recursive not over dirs by default
// ignoredefault bool = true // ignore files starting with . and _
// ```
// .
// example see https://github.com/freeflowuniverse/crystallib/blob/development_circles/examples/core/pathlib/examples/list/path_list.v
// .
// e.g. p.list(regex:[r'.*\.v$'])!  //notice the r in front of string, this is regex for all files ending with .v
// .
// please note links are ignored for walking over dirstructure (for files and dirs)
pub fn (path Path) list(args_ ListArgs) !PathList {
	mut r := []regex.RE{}
	for regexstr in args_.regex {
		mut re := regex.regex_opt(regexstr) or {
			return error("cannot create regex for:'${regexstr}'")
		}
		// println(re.get_query())
		r << re
	}
	mut args := ListArgsInternal{
		regex: r
		recursive: args_.recursive
		ignoredefault: args_.ignoredefault
	}
	paths := path.list_internal(args)!
	mut pl := PathList{
		root: path.path
		paths: paths
	}
	return pl
}

[params]
pub struct ListArgsInternal {
mut:
	regex         []regex.RE //only put files in which follow one of the regexes
	recursive     bool = true
	ignoredefault bool = true // ignore files starting with . and _
}

fn (path Path) list_internal(args ListArgsInternal) ![]Path {
	if path.cat !in [Category.dir] {
		// return error('Path must be directory or link to directory')
		return []Path{}
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
		if new_path.is_link() {
			continue
		}		
		if args.ignoredefault {
			if item.starts_with('_') || item.starts_with('.') {
				continue
			}
		}		
		if new_path.is_dir() {
			// If recusrive
			if args.recursive {
				mut rec_list := new_path.list_internal(args)!
				all_list << rec_list
			}
			continue
		}
		mut addthefile := true
		for r in args.regex {
			if !(r.matches_string(item)) {
				addthefile = false
			}
		}
		if addthefile {
			all_list << new_path
		}
	}
	return all_list
}

// // find dir underneith path .
// // see path.list() for more info in how to use the args
// pub fn (path Path) dir_list(args ListArgs) !PathList {
// 	mut pl := path.list(args)!
// 	pl.paths = pl.paths.filter(it.cat == Category.dir)
// 	return pl
// }

// // find file underneith path .
// // see path.list() for more info in how to use the args
// pub fn (path Path) file_list(args ListArgs) !PathList {
// 	mut pl := path.list(args)!
// 	pl.paths = pl.paths.filter(it.cat == Category.file)
// 	return pl
// }

// // find links (don't follow) .
// // see path.list() for more info in how to use the args
// pub fn (mut path Path) link_list(args ListArgs) !PathList {
// 	mut pl := path.list(args)!
// 	pl.paths = pl.paths.filter(it.cat in [Category.linkdir, Category.linkfile])
// 	return pl
// }

// copy all
pub fn (mut pathlist PathList) copy(dest string) ! {
	for mut path in pathlist.paths {
		path.copy(dest:dest)!
	}
}

// delete all
pub fn (mut pathlist PathList) delete() ! {
	for mut path in pathlist.paths {
		path.delete()!
	}
}

// sids_acknowledge .
pub fn (mut pathlist PathList) sids_acknowledge(cid smartid.CID) ! {
	for mut path in pathlist.paths {
		path.sids_acknowledge(cid)!
	}
}

// sids_replace .
// find parts of text in form sid:*** till sid:******  .
// replace all occurrences with new sid's which are unique .
// cid = is the circle id for which we find the id's .
// sids will be replaced in the files if they are different
pub fn (mut pathlist PathList) sids_replace(cid smartid.CID) ! {
	for mut path in pathlist.paths {
		path.sids_replace(cid)!
	}
}
