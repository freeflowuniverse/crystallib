module tfgrid

import freeflowuniverse.crystallib.redisclient


pub struct TFGridClient {
pub mut:
	redis &redisclient.Redis [str: skip]
}


fn new()! TFGridClient {
	mut redis := redisclient.core_get()
	mut cl:=TFGridClient{
		redis=redis
	}
}



fm (mut cl TFGridClient) rpc(cmd string,data string) !string{

}