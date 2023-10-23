module osal
import os
import freeflowuniverse.crystallib.core.pathlib

[params]
pub struct RsyncArgs {
pub mut:
	source string
	dest string
	delete bool //do we want to delete the destination
	ipaddr_src string //e.g. root@192.168.5.5:33 (can be without root@ or :port)
	ipaddr_dst string
	ignore []string //arguments to ignore e.g. ['*.pyc','*.bak']
	ignore_default bool = true //if set will ignore a common set
	stdout bool = true
}


// flexible tool to sync files from to, does even support ssh .
// args: .
// ```
// 	source string
// 	dest string
// 	delete bool //do we want to delete the destination
//  ipaddr_src string //e.g. root@192.168.5.5:33 (can be without root@ or :port)
//  ipaddr_dst string //can only use src or dst, not both
// 	ignore []string //arguments to ignore
//  ignore_default bool = true //if set will ignore a common set
//  stdout bool = true
// ```
// .
// see https://github.com/freeflowuniverse/crystallib/blob/development_circles/examples/osal/rsync/rsync_example.v
pub fn rsync(args RsyncArgs) ! {
	cmd:=rsync_cmd(args)!
	if args.ipaddr_src.len==0{
		pathlib.get_dir(path:args.source,false)!
	}
	// println(cmd)
	if args.stdout{
		execute_stdout(cmd)!
	}else{
		execute_silent(cmd)!
	}
}

//return the cmd with all rsync arguments .
// see rsync for usage of args
pub fn rsync_cmd(args_ RsyncArgs) !string {
	mut args:=args_
	mut cmd:=""

	//normalize
	args.source=os.norm_path(args.source)
	args.dest=os.norm_path(args.dest)

	mut delete:=""
	if args.delete{
		delete="--delete"
	}	
	options:="-avz --no-perms"
	mut sshpart:=""
	mut addrpart:=""
	
	mut exclude:=""
	if args.ignore_default{
		defaultset:=['*.pyc','*.bak',"*dSYM"]
		for item in defaultset{
			if !(item in args.ignore){
				args.ignore<<item
			}
		}
	}	
	for excl in args.ignore{
		exclude+= " --exclude='${excl}'"
	}

	args.source = args.source.trim_right("/ ")+"/"
	args.dest = args.dest.trim_right("/ ")+"/"

	if args.ipaddr_src.len>0 && args.ipaddr_dst.len==0{
		sshpart,addrpart=rsync_ipaddr_format(args.ipaddr_src)
		cmd= 'rsync  ${options} ${delete} ${exclude} ${sshpart} ${addrpart}:${args.source} ${args.dest}'
	}else if args.ipaddr_dst.len>0 && args.ipaddr_src.len==0{
		sshpart,addrpart=rsync_ipaddr_format(args.ipaddr_dst)
		cmd= 'rsync  ${options} ${delete} ${exclude} ${sshpart} ${args.source} ${addrpart}:${args.dest}'
	}else if args.ipaddr_dst.len>0 && args.ipaddr_src.len>0{
		return error("cannot have source and dest as ssh")
	}else{		
		cmd= 'rsync ${options} ${delete} ${exclude} ${args.source} ${args.dest}'
	}
	return cmd
}

fn rsync_ipaddr_format(ipaddr_ string) (string,string) {
	mut ipaddr:=ipaddr_
	mut user:="root"
	mut port:="22"
	if ipaddr.contains("@"){
		user ,ipaddr = ipaddr.split_once('@') or {panic('bug')}
	}
	println("- '${ipaddr_}' $user $ipaddr")
	if ipaddr.contains(":"){
		ipaddr,port = ipaddr.rsplit_once(':') or {panic('bug')}
	}
	if ipaddr.len==0{
		panic("ip addr cannot be empty")
	}
	return "-e \'ssh -p ${port}\'","${user}@${ipaddr}"
}




