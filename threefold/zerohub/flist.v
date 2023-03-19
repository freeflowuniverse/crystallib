module tfgrid



pub struct TFGridClient {
pub mut:
	redis &redisclient.Redis [str: skip]
}

[params]
pub struct FlistGet{
pub:
	reset bool
}


//structure which represents flist
pub struct Flist{
pub:	
	flisturl string //full path to downloadable flist
}





pub fn (mut cl TFGridClient) flists_get(args FlistGet)! []Flist {
	//TODO: use our caching rest client (httpclient)
	//example which was working: curl -H "Authorization: bearer 6Pz6giOpHSaA3KdYI6LLpGSLmDmzmRkVdwvc7S-E5PVB0-iRfgDKW9Rb_ZTlj-xEW4_uSCa5VsyoRsML7DunA1sia3Jpc3RvZi4zYm90IiwgMTY3OTIxNTc3MF0=" https://hub.grid.tf/api/flist/
	//see how to get this Authorization bearer to work with our httpclient
	if args.reset{
		//TODO: clean redis cache
	}
	return []Flist{}
}