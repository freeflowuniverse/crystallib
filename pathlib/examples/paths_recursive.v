module main

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.params
import os

const testpath3 = os.dir(@FILE) + '/test_path'

// if we return True then it means the dir or file is processed
fn filter_1(mut path pathlib.Path, mut params params.Params) !bool {
	// print(" - check $path.path")
	if path.name().starts_with('.') {
		// println(" FALSE")
		return false
	} else if path.name().starts_with('_') {
		// println(" FALSE")
		return false
	}
	// println(" TRUE")
	return true
}

fn executor_1(mut patho pathlib.Path, mut params params.Params) !params.Params {
	// println("- ${patho.path}")
	// println( " - exec: $patho.path" )
	params.arg_add(patho.path)
	return params
}

fn do() ! {
	mut p := pathlib.get_dir(testpath3, false)!
	mut params := params.Params{}
	mut params2 := p.scan(mut params, [filter_1], [executor_1])!
	println(params2)
}

fn main() {
	do() or { panic(err) }
}
