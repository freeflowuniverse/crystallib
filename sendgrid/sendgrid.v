module sendgrid

pub struct Client {
 pub: 
 	token  string
	source string
	api_url string
}

[params]
pub struct Credintials {
	pub: 
	source string
	token string
	api string
}

pub fn new_sendgrid_client(cred Credintials ) !Client{
	return Client{
		token: cred.token
		api_url: cred.api
		source: cred.source
	}
}

