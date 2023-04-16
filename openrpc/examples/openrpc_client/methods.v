module openrpc_client 

pub fn (client Client) hello() {
	println('hello')
}

pub fn (client Client) ping() string {
	return 'pong'
}

[params]
pub struct AnimalArgs {
	name string
	species string
}

// create_animal adds an animal with the provided arguments to the database
pub fn (client Client) create_animal(args AnimalArgs) {
	println('Creating animal `$args.name`')
}

// get_animal finds an animal in the database with the provided name
// returns the animal, an animal in the db with a matching name
pub fn (client Client) get_animal(name string) Animal {
	return Animal{}
}