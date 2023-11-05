module archiver

// import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.paramsparser

fn filter_base(mut path pathlib.Path, mut params paramsparser.Params) !bool {
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

fn executor(mut patho pathlib.Path, mut params paramsparser.Params) !paramsparser.Params {
	println(' - exec: ${patho.path}')
	if patho.is_dir {
	}
	return params
}

type Filter0 = fn (mut Path, mut paramsparser.Params) bool

type Executor0 = fn (mut Path, mut paramsparser.Params) !paramsparser.Params

pub fn (mut a Archiver) add() ! {
	mut p := pathlib.get_dir(path: testpath)!
	mut params := paramsparser.Params{}
	params.kwarg_set('path_meta')
	params.kwarg_set('path_stor')
	mut params2 := p.scan(mut params, [filter_base], [executor])!
}

// pub fn (mut path Path) scan(mut params paramsparser.Params, filters []Filter0, executors []Executor0) !paramsparser.Params {
// 	if !path.is_dir() {
// 		return error('can only scan on dir')
// 	}
// 	return scan_recursive(mut path, mut params, filters, executors)
// }
