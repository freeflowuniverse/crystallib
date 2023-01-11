
module rmbprocessor
import freeflowuniverse.crystallib.rmbclient
import freeflowuniverse.crystallib.encoder
import net.websocket

//client to the rmb proxy
pub struct RMBProxyClient{
pub mut:
	rmb rmbclient.RMBClient
	twinid u32
	proxyipaddrs []string
	websocketclients []string //in reality its not string, its webdav clients, is more than 1
	websocketclient_active u8 //the current webdavclient which is being used, the one which is active
}

//call first webdavclient first, if it doesn't work use next one, ...
fn (mut cl RMBProxyClient) rpc(data map[string]string)! map[string]string{
	//todo: check the webdavclient is ok (phase 2)
	//todo: implement how do we know what is working and what not (phase 2)
	mut webdavclient:=cl.webdavclients[webdavclient_active]
	//todo: implement the call over the client
	encoder := encoder.encoder_new()
	encoder.add_map_string(data)
	encoder.data //todo: this needs to be send over the rpc to proxy 
	return map[string]string{}
}


//this needs to go to a thread, so it can be executing at background
pub fn proxy_processor(twinid u32, proxyipaddrs []string){
	mut rmb :=rmbclient.new()!
	mut cl:=RMBProxyClient{rmb:rmb,twinid:twinid,proxyipaddrs:proxyipaddrs}
	for proxyipaddr in cl.proxyipaddrs{
		mut wscl:=websocket.new_client(proxyipaddr,ClientOpt{})!
		cl.websocketclients<<wscl
	}
	
}


pub fn (mut cl RMBProxyClient) job_send(args rmbclient.ActionJob)!{
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

