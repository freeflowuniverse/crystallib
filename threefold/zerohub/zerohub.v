module zerohub


//TODO: curl -H "Authorization: bearer 6Pz6giOpHSaA3KdYI6LLpGSLmDmzmRkVdwvc7S-E5PVB0-iRfgDKW9Rb_ZTlj-xEW4_uSCa5VsyoRsML7DunA1sia3Jpc3RvZi4zYm90IiwgMTY3OTIxNTc3MF0=" https://hub.grid.tf/api/flist/


pub struct ZeroHubClient {
pub mut:
	url string

}

[params]
pub struct ZeroHubClientArgs {
pub:
	url string = "hub.grid.tf"

}

//see https://hub.grid.tf/
// more info see https://github.com/threefoldtech/0-hub#public-api-endpoints-no-authentication-needed
pub fn new(args ZeroHubClientArgs)! ZeroHubClient {
	mut cl:=ZeroHubClient{
		url:args.url
	}
	//TODO: there should be a check here that its accessible
	return cl
}
