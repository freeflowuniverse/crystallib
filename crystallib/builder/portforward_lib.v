module builder


import freeflowuniverse.crystallib.osal.screen
import freeflowuniverse.crystallib.data.ipaddress

@[params]
pub struct ForwardArgsToLocal {
pub mut:
	name string  @[required]
	address string @[required]
	remote_port int  @[required]
	local_port int
	user string = "root"
}

// forward a remote port on ssh host to a local port
pub fn portforward_to_local(args_ ForwardArgsToLocal) ! {
	mut args:=args_
	if args.local_port==0{
		args.local_port=args.remote_port
	}
	mut addr := ipaddress.new(args.address)!
	mut cmd := 'ssh -L ${args.local_port}:localhost:${args.remote_port} ${args.user}@${args.address}'
	if addr.cat==.ipv6{
		cmd = 'ssh -L ${args.local_port}:localhost:${args.remote_port} ${args.user}@${args.address.trim("[]")}'
	}
	println(cmd)
	mut scr:=screen.new(reset:false)!
	mut s2:=scr.add(name:args.name,cmd:cmd)!

}
