
//if rmbid is 0, means we work in local mode
// 		src_twinid		 u32    //which twin is responsible for executing on behalf of actor (0 is local)
// 		src_rmbids		 []u32  //how do we find our way back, if 0 is local, can be more than 1
// 		ipaddr			 string
pub fn (mut rmbp RMBProcessor) iam_register(args MyTwin)!{
	mut rmb:=rmbp.rmbc
	
	mut ipaddr0:=args.ipaddr
	if ipaddr0==""{
		ipaddr0="localhost"
	}
	ipaddr:=ipaddress.ipaddress_new(ipaddr0)!
	twin:=MyTwin {
		src_twinid: args.src_twinid
		src_rmbids:args.src_rmbids
		ipaddr:ipaddr0
	}
	data:=twin.dumps()!
	rmb.redis.set("rmb.iam",data)!
	rmb.iam=twin
}

