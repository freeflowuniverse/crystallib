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


//6Pz6giOpHSaA3KdYI6LLpGSLmDmzmRkVdwvc7S-E5PVB0-iRfgDKW9Rb_ZTlj-xEW4_uSCa5VsyoRsML7DunA1sia3Jpc3RvZi4zYm90IiwgMTY3OTIxNTc3MF0=
//curl -H "Authorization: bearer 6Pz6giOpHSaA3KdYI6LLpGSLmDmzmRkVdwvc7S-E5PVB0-iRfgDKW9Rb_ZTlj-xEW4_uSCa5VsyoRsML7DunA1sia3Jpc3RvZi4zYm90IiwgMTY3OTIxNTc3MF0=" https://hub.grid.tf/api/flist/me