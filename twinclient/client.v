module twinclient

import threefoldtech.rmb.twinclient { TwinClient, new }

const redis_server = 'localhost:6379' //Change it with Your redis server
const twin_dest = 35 //Change it with Your Twin Id

pub struct Client {
	TwinClient
}

pub fn init(redis_server string, twin_dist int) ?Client {
	/*
	Create a new Client isntance
		Inputs:
			- redis_server (string): Redis server and port number ex: 'localhost:6379'
			- twin_dist (int): Your twin id.
		Output:
			- Client: new Client instance
	*/
	return Client{new(redis_server, twin_dist) ?}
}
