module handler

pub interface IHandler {
	handle[T, D](string, T) D
}

pub struct Handler {
	methods []
}

pub fn (mut handler Handler) register

pub fn (handler Handler) handle[T, D](method string, payload T) D {

}

