module main

pub fn plain_method() {
}

pub fn method_with_body() {
	println('Example method evoked.')
}

// this method has a comment
pub fn method_with_comment() {
}

pub fn method_with_param(param string) {
}

pub fn method_with_return() string {
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
