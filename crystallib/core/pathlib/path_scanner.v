module pathlib

import freeflowuniverse.crystallib.data.paramsparser

type Filter0 = fn (mut Path, mut paramsparser.Params) !bool

type Executor0 = fn (mut Path, mut paramsparser.Params) !paramsparser.Params

// the filters are function which needs to return true if to process with alle executors .
// see https://github.com/freeflowuniverse/crystallib/blob/development/examples/core/pathlib/examples/scanner/path_scanner.v .
// if any of the filters returns false then we don't continue .
// if we return True then it means the dir or file is processed .
// .
// type Filter0 = fn (mut Path, mut paramsparser.Params) bool
// type Executor0 = fn (mut Path, mut paramsparser.Params) !paramsparser.Params
//
pub fn (mut path Path) scan(mut parameters paramsparser.Params, filters []Filter0, executors []Executor0) !paramsparser.Params {
	if !path.is_dir() {
		return error('can only scan on dir.\n${path}')
	}
	return scan_recursive(mut path, mut parameters, filters, executors)
}

fn scan_recursive(mut path Path, mut parameters paramsparser.Params, filters []Filter0, executors []Executor0) !paramsparser.Params {
	// console.print_debug("recursive: $path")
	// walk over filters if any of them returns false return and don't process
	for f in filters {
		needs_to_be_true := f(mut path, mut parameters) or {
			msg := 'Cannot filter for ${path.path}\n${error}'
			// console.print_debug(msg)
			return error(msg)
		}
		if !needs_to_be_true {
			return parameters
		}
	}
	if path.is_dir() {
		for e in executors {
			parameters = e(mut path, mut parameters) or {
				msg := 'Cannot process execution on dir ${path.path}\n${error}'
				// console.print_debug(msg)
				return error(msg)
			}
		}
		mut pl := path.list(recursive: false) or {
			return error('cannot list: ${path.path} \n${error}')
		}
		// llist.sort()
		// first process the files and link
		for mut p_in in pl.paths {
			if !p_in.is_dir() {
				scan_recursive(mut p_in, mut parameters, filters, executors) or {
					msg := 'Cannot process recursive on ${p_in.path}\n${error}'
					// console.print_debug(msg)
					return error(msg)
				}
			}
		}
		// now process the dirs
		for mut p_in in pl.paths {
			if p_in.is_dir() {
				scan_recursive(mut p_in, mut parameters, filters, executors) or {
					msg := 'Cannot process recursive on ${p_in.path}\n${error}'
					// console.print_debug(msg)
					return error(msg)
				}
			}
		}
	} else {
		for e in executors {
			parameters = e(mut path, mut parameters) or {
				msg := 'Cannot process execution on file ${path.path}\n${error}'
				// console.print_debug(msg)
				return error(msg)
			}
		}
	}
	return parameters
}
