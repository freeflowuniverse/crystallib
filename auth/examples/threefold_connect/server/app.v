module main

import vweb

struct ServerApp {
	vweb.Context
}

fn main() {
	println('Server app started')
	vweb.run(&ServerApp{}, 8000)
}

pub fn (mut server ServerApp) abort(status int, message string) {
	server.set_status(status, message)
	er := CustomResponse{status, message}
	server.json(er.to_json())
}
