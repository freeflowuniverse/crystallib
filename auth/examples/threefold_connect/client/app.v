module main
import vweb
import term

// To run client app
struct ClientApp {
	vweb.Context
}

pub fn (mut client ClientApp)abort(status int, message string){
	client.set_status(status, message)
	er := CustomResponse{status, message}
	client.json(er.to_json())
}

fn main() {
	println(term.green('Client app started'))
	vweb.run(&ClientApp{}, 8080)
}
