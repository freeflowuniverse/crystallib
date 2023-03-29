module tfgrid

pub struct Credentials {
	mnemonics string
	network   string //TODO: that should not be a string, work with enum, check enum inside login
}


pub fn (mut client TFGridClient) login(credentials Credentials) ! {
	retqueue := client.rpc.call[Credentials]('tfgrid.login', credentials)!
	client.rpc.result[string](5000, retqueue)!
}
