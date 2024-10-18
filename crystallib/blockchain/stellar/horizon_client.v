module stellar

import freeflowuniverse.crystallib.clients.httpconnection
import json

pub struct HorizonClient {
pub mut:	
	url         string
}


pub fn  new_horizon_client() !HorizonClient {
	mut cl:=HorizonClient{url:"https://horizon.stellar.org"}
	return cl

}

pub fn (self HorizonClient) get_account(pubkey string) !StellarAccount {
	
	mut client := httpconnection.new(name: 'horizon', url: self.url)!	

	result := client.get_json(
		prefix: 'accounts/${pubkey}'
		debug:true
		cache_disable:false
	)!

	mut a:=json.decode(StellarAccount, result) or {
			return error('Failed to create StellarAccount: error: ${result}')
		}
	
	//println(a)

	return a
}