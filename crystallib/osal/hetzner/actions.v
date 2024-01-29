module hetzner
import json
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.clients.redisclient
import time
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal { ping }
import net.urllib
import freeflowuniverse.crystallib.builder

/////////////////////////// LIST

pub struct ServerInfo {
pub mut:	
	server_ip string
	server_ipv6_net string
	server_number int
	server_name string
	product string
	dc string
	traffic string
	status string
	cancelled bool
	paid_until string
	ip []string
	subnet []Subnet
}

pub struct Subnet {
pub mut:	
	ip string
	mask string
}

struct ServerRoot {
	server ServerInfo
}

pub fn (h HetznerClient) servers_list() ![]ServerInfo {

	mut redis := redisclient.core_get()!
	mut rkey:='hetzner.api.list.${h.instance}'
	mut data:=redis.get(rkey)!
	if data=="" {
		data = h.request_get("/server")!
	}

	redis.set(rkey,data)!
	redis.expire(rkey, 60)! //only cache for 1 minute

	// println(data)

	srvs := json.decode([]ServerRoot, data) or {
		return error("could not json deserialize for servers_list\n$data")
	}

	mut result := srvs.map(it.server)
	return result
}

///////////////////////////GETID

pub struct ServerGetArgs {
pub mut:	
	id int
	name string
}

pub fn (h HetznerClient) server_info_get(args_ ServerGetArgs) !ServerInfo {
	
	mut args:=args_

	args.name=texttools.name_fix(args.name)

	l:=h.servers_list()!

	mut res:=[]ServerInfo{}

	for item in l{
		if args.id>0 && item.server_number!=args.id{
			continue
		}
		server_name := texttools.name_fix(item.server_name)
		if args.name.len>0 && server_name!=args.name{
			continue
		}
		res<<item
	}

	if res.len>1{
		return error("Found too many servers with: '${args}'")
	}
	if res.len==0{
		return error("couldn't find server with: '${args}'")
	}
	return res[0] or {panic("bug")}
	
}


///////////////////////////RESCUE


pub struct RescueInfo {
pub mut:		
    server_ip string
    server_ipv6_net string
    server_number int
    os string
    arch int
    active bool
    password string
    authorized_key []string
    host_key []string
}


struct RescueRoot{
	rescue RescueInfo
}

pub struct ServerRescueArgs {
pub mut:	
	id int
	name string
	wait bool = true
	crystal_install bool
}

//put server in rescue mode
pub fn (h HetznerClient) server_rescue(args ServerRescueArgs) !RescueInfo {

	mut serverinfo:= h.server_info_get(id:args.id,name:args.name)!

	console.print_header("server ${serverinfo.server_name} goes into rescue mode")

	keys:=h.keys_get()!

	mut keysdata :=""
	for key in keys{
		keysdata+=key.fingerprint+"&"
	}
	keysdata=keysdata.trim("&")
	
	mut nv:=urllib.new_values()
	nv.add("os","linux")
	nv.add("authorized_key",keysdata)
	data:=nv.encode()

	//TODO: see what happens if there are more than 1 key

	response := h.request_post("/boot/${serverinfo.server_number}/rescue", data)!

	if response.status_code != 200 {
		return error("could not process request: error $response.status_code $response.body")
	}

	rescue := json.decode(RescueRoot, response.body) or {
		return error("could not process request.\n$response.body")
	}

	h.server_reset(id:args.id,name:args.name,wait:args.wait)!

	if args.crystal_install{
		mut b := builder.new()!
		mut n := b.node_new(ipaddr: serverinfo.server_ip)!
		n.crystal_install()!
	}

	return rescue.rescue
}





/////////////////////////////////////RESET


struct ResetInfo {
	server_ip string
    server_ipv6_net string
    server_number int
    // type string // FIXME
    operating_status string
}

struct ResetRoot {
	reset ResetInfo
}

pub struct ServerRebootArgs {
pub mut:	
	id int
	name string
	wait bool = true
}


pub fn (h HetznerClient) server_reset(args ServerRebootArgs) !ResetInfo {

	mut serverinfo:= h.server_info_get(id:args.id,name:args.name)!

	console.print_header("server ${serverinfo.server_name} goes for reset")

	mut serveractive:=false
	if ping(address: serverinfo.server_ip) == .ok{
		serveractive = true
		console.print_debug("server ${serverinfo.server_name} is active")
	}else{
		console.print_debug("server ${serverinfo.server_name} is down")
	}
	
	response := h.request_post("/reset/${serverinfo.server_number}", "type=hw")!

	if response.status_code != 200 {
		return error("could not process request: error $response.status_code $response.body")
	}

	o := json.decode(ResetRoot, response.body) or {
		return error("could not process request")
	}

	//now need to wait till it goes off
	if serveractive{
		for{
			console.print_debug("wait for server ${serverinfo.server_name} to go down.")
			if ping(address: serverinfo.server_ip) != .ok{
				console.print_debug("server ${serverinfo.server_name} is now down, now waitig for reboot.")
				break
			}
			time.sleep(1000 * time.millisecond)
		}		
	}

	mut x:=0
	if args.wait{
		for{
			time.sleep(1000 * time.millisecond)
			console.print_debug("wait for ${serverinfo.server_name}")
			if ping(address: serverinfo.server_ip) == .ok{
				console.print_header("server is rebooted: ${serverinfo.server_name}")
				break
			}
			x+=1
			if x>60*5{
				//5 min
				return error("Could not reboot server ${serverinfo.server_name} in 5 min")
			}
		}
	}

	return o.reset
}

/////////////////////////////////////BOOT




struct BootRoot {
	boot Boot
}


struct Boot {
	rescue RescueInfo
}


pub fn (h HetznerClient) server_boot(id int) !RescueInfo {
	data := h.request_get("/boot/$id")!

	println(data)

	if true{
		panic("serverboot")
	}

	boot := json.decode(BootRoot, data) or {
		return error("could not process request: $err")
	}

	return boot.boot.rescue
}
