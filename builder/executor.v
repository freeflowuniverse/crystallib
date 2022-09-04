module builder

// [heap]
// interface Executor {
// mut:
// 	exec(cmd string) ?string
// 	exec_silent(cmd string) ?string
// 	file_write(path string, text string) ?
// 	file_read(path string) ?string
// 	file_exists(path string) bool
// 	delete(path string) ?
// 	download(source string, dest string) ?
// 	upload(source string, dest string) ?
// 	environ_get() ?map[string]string
// 	info() map[string]string
// 	shell(cmd string) ?
// 	list(path string) ?[]string
// 	dir_exists(path string) bool
// 	debug_off()
// 	debug_on()
// }

type Executor = ExecutorSSH | ExecutorLocal

pub struct ExecutorNewArguments {
	local  bool //if this set then will always be the local machine
	ipaddr string
	user   string = "root"
	debug  bool
	}

// create new executor (is way how to execute in std way onto a local or remote machine)
// pub struct ExecutorNewArguments {
// 	local  false //if this set then will always be the local machine
// 	ipaddr string
// 	user   string = "root"
// 	debug  bool
// 	}
//- format ipaddr: 192.168.6.6:7777
//- format ipaddr: 192.168.6.6
//- format ipaddr: any ipv6 addr
//- if ipaddr is empty or starts with localhost or 127.0.0.1 -> will be the ExecutorLocal
fn executor_new(args ExecutorNewArguments)?Executor{
		if args.ipaddr == '' || args.ipaddr.starts_with('localhost') || args.ipaddr.starts_with('127.0.0.1') 
		{
			return ExecutorLocal{debug:args.debug}
		}else{
			ipaddr := ipaddress_new(args.ipaddr) or { return error('can not initialize ip address') }
			return ExecutorSSH{
					ipaddr: ipaddr
					user: args.user
					debug: args.debug
				}
		}
}