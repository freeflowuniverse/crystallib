module rmbprocessor

import freeflowuniverse.crystallib.ipaddress

import json

//if rmbid is 0, means we work in local mode
// 		src_twinid		 u32    //which twin is responsible for executing on behalf of actor (0 is local)
// 		src_rmbids		 []u32  //how do we find our way back, if 0 is local, can be more than 1
// 		ipaddr			 string
pub fn (mut rmbp RMBProcessor) iam_register(args MyTwin) ! {
	mut rmb := &rmbp.rmbc
	
	mut ipaddr0 := args.ipaddr
	if ipaddr0 == "" {
		ipaddr0 = "localhost"
	}
	ipaddr := ipaddress.ipaddress_new(ipaddr0)!
	twin := MyTwin {
		twinid: args.twinid
		rmb_proxy_ips: args.rmb_proxy_ips
		ipaddr: ipaddr0
	}

	//rmb.redis.set("rmb.iam", json.encode(twin))!
	rmb.twinid = twin.twinid
}

