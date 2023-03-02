module cacher

// import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.params

fn filter_base(mut path pathlib.Path, mut params params.Params) !bool {
	// print(" - check $path.path")
	if path.name().starts_with('.') {
		// println(" FALSE")
		return false
	} else if path.name().starts_with('_') {
		// println(" FALSE")
		return false
	} else if path.name().to_lower().ends_with('.bak') {
		// println(" FALSE")
		return false
	}
	// println(" TRUE")
	return true
}

fn executor(mut patho pathlib.Path, mut params params.Params) !params.Params {
	println(' - exec: ${patho.path}')
	if patho.is_dir {
	}
	return params
}

type Filter0 = fn (mut Path, mut params.Params) bool

type Executor0 = fn (mut Path, mut params.Params) !params.Params

// pub fn (mut path Path) scan(mut params params.Params, filters []Filter0, executors []Executor0) !params.Params {
// 	if !path.is_dir() {
// 		return error('can only scan on dir')
// 	}
// 	return scan_recursive(mut path, mut params, filters, executors)
// }

pub fn (mut a Archiver) add() ! {
	mut p := pathlib.get_dir(testpath, false)!
	mut params := params.Params{}
	params.kwarg_add('path_meta')
	params.kwarg_add('path_stor')
	mut params2 := p.scan(mut params, [filter_base], [executor])!
}
