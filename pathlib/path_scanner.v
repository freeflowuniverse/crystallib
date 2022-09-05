module pathlib

import params

type Filter0 = fn (mut Path, mut params.Params) ?bool

type Executor0 = fn (mut Path, mut params.Params) ?params.Params

// the filters are function which needs to return true if to process with alle executors
// see examples dir in pathlib to see how to use
// if any of the filters returns false then we don't continue
// if we return True then it means the dir or file is processed
//```
// fn filter_1(mut path pathlib.Path, mut params params.Params) ?bool{
// 	// print(" - check $path.path")
// 	if path.name().starts_with('.') {
// 		// println(" FALSE")
// 		return false
// 	} else if path.name().starts_with('_') {
// 		// println(" FALSE")
// 		return false
// 	}
// 	// println(" TRUE")
// 	return true
// }

// fn executor_1(mut patho pathlib.Path, mut params params.Params)?params.Params{
// 	// println("- ${patho.path}")
// 	// println( " - exec: $patho.path" )
// 	params.arg_add(patho.path)
// 	return params
// }

// 	mut p := pathlib.get_dir(testpath,false)?
// 	mut params := params.Params{}
// 	mut params2 := p.scan(mut params, [filter_1], [executor_1])?
// 	println( params2)
//```
//
// type Filter0 = fn (mut Path, mut params.Params) bool
// type Executor0 = fn (mut Path, mut params.Params) ?params.Params
//
pub fn (mut path Path) scan(mut params params.Params, filters []Filter0, executors []Executor0) ?params.Params {
	if !path.is_dir() {
		return error('can only scan on dir')
	}
	return scan_recursive(mut path, mut params, filters, executors)
}

fn scan_recursive(mut path Path, mut params params.Params, filters []Filter0, executors []Executor0) ?params.Params {
	// println("recursive: $path")
	// walk over filters if any of them returns false return and don't process
	for f in filters {
		needs_to_be_true := f(mut path, mut params) or {
			msg := 'Cannot filter for $path.path\n$error'
			// println(msg)
			return error(msg)			
		}
		if !needs_to_be_true {
			return params
		}
	}
	if path.is_dir() {
		mut llist := path.list(recursive: false) or {
			return error("cannot list: $path.path \n$error")
		}
		for mut p_in in llist {
			scan_recursive(mut p_in, mut params, filters, executors)  or {
				msg := 'Cannot process recursive on $p_in.path\n$error'
				// println(msg)
				return error(msg)
			}
		}
	} else {
		for e in executors {
			params = e(mut path, mut params) or {
				msg := 'Cannot process execution on file $path.path\n$error'
				// println(msg)
				return error(msg)
			}
		}
	}
	return params
}
