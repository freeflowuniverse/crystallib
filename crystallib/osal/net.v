module osal

pub enum PingResult {
	ok
	timeout // timeout from ping
	unknownhost // means we don't know the hostname its a dns issue
}

[params]
pub struct PingArgs {
pub mut:
	address string @[required]
	count   u8  = 1 // the ping is successful if it got count amount of replies from the other side
	timeout u16 = 1 // the time in which the other side should respond in seconds
	retry   u8
}

// if reached in timout result will be True
// address is e.g. 8.8.8.8
// ping means we check if the destination responds
pub fn ping(args PingArgs) PingResult {
	mut cmd := ''
	platform_ := platform()
	if platform_ == .osx {
		cmd = 'ping -c ${args.count} -t ${args.timeout} ${args.address}'
	} else if platform_ == .ubuntu {
		cmd = 'ping -c ${args.count} -w ${args.timeout} ${args.address}'
	} else {
		panic('Unsupported platform for ping')
	}
	_ := exec(cmd: cmd, retry: args.retry, timeout: 0, stdout: false) or {
		if err.code() == 9999 {
			return .timeout
		}
		if platform_ == .osx {
			return match err.code() {
				2 { .timeout }
				68 { .unknownhost }
				else { panic(err.msg()) }
			}
		} else if platform_ == .ubuntu {
			return match err.code() {
				1 { .timeout }
				2 { .unknownhost }
				else { panic(err.msg()) }
			}
		} else {
			panic(err.msg())
		}
	}
	return .ok
}

// Returns the ipaddress as known on the public side
// is using resolver4.opendns.com
pub fn ipaddr_pub_get() !string {
	cmd := 'dig @resolver4.opendns.com myip.opendns.com +short'
	ipaddr := exec(cmd: cmd)!
	return ipaddr.output.trim('\n').trim(' \n')
}
