module twinsafe

pub struct GetError {
	Error
mut:
	args        GetArgs
	error_type 	GetErrorType
	msg string
}

pub enum GetErrorType {
	notfound
	error
}

fn (err GetError) msg() string {
	if err.error_type == .double {
		return 'More than 1 object found:\n${err.args}'
	}
	mut msg := 'Could not get object.\n${err.msg}\n${err.args}'
	return msg
}

fn (err GetError) code() int {
	return int(err.error_type)
}

[params]
//standardised way how to get an object
pub struct GetArgs{
pub:
	name string
	id u32
}

