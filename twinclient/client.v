module twinclient

import threefoldtech.rmb.twinclient { TwinClient, new }

pub struct Client {
	TwinClient
}

// Create a new Client instance using redis_server and twin_id
pub fn init(redis_server string, twin_id int) ?Client {
	return Client{new(redis_server, twin_id)?}
}
