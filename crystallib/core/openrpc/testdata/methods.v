module main
import freeflowuniverse.crystallib.ui.console

pub fn plain_method() {
}

pub fn method_with_body() {
	console.print_debug('Example method evoked.')
}

// this method has a comment
pub fn method_with_comment() {
}

pub fn method_with_param(param string) {
}

pub fn method_with_return() string {
	return ''
}

@[params]
pub struct Params {
	param1 int
	param2 string
	param3 []int
	param4 []string
}

pub fn method_with_params(a Params) {
}
