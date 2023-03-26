module zerohub
import net.http

// ZeroHubClient is the main struct that holds the values and methods.
pub struct ZeroHubClient {
pub mut:
	url    string
	token  string
	header http.Header
}

// ZeroHubClientArgs is the args needed to construct the ZeroHubClient.
[params]
pub struct ZeroHubClientArgs {
pub:
	url    string = 'hub.grid.tf'
	token  string
	header http.Header
}

// Create new ZeroHubClient from the ZeroHubClientArgs
pub fn new(args ZeroHubClientArgs) !ZeroHubClient {
	// mut conn := httpconnection.new(name:'zerohub', url:'https://${args.url}')	

	// TODO: use our caching rest client (httpclient)
	// example which was working: curl -H "Authorization: bearer ""..." https://hub.grid.tf/api/flist/
	// see how to get this Authorization bearer to work with our httpclient, certain header to be set.
	// if args.reset {
	// 	//if reset asked for cache will be emptied
	// 	conn.cache.cache_drop()!
	// }
	// TODO: there should be a check here that its accessible


	header_config := http.HeaderConfig{
		key: http.CommonHeader.authorization
		value: 'Bearer ${args.token}'
	}
	header := http.new_header(header_config)

	mut cl := ZeroHubClient{
		url: args.url
		token: args.token
		header: header
	}

	return cl
}
