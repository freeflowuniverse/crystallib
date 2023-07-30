module osal

pub enum PingResult {
	ok
	timeout
	unknownhost
}

[params]
pub struct PingArgs {
pub mut:
	address string [required]
	count   u8  = 1 // the ping is successful if it got count amount of replies from the other side
	timeout u16 = 1 // the time in which the other side should respond in seconds
	retry   u8  = 0
}

// if reached in timout result will be True
// address is e.g. 8.8.8.8
// ping means we check if the destination responds
pub fn ping(args PingArgs) PingResult {
	mut cmd := ''
	if platform() == .osx {
		cmd = 'ping -c ${args.count} -t ${args.timeout} ${args.address}'
	} else {
		cmd = 'ping -c ${args.count} -w ${args.timeout} ${args.address}'
	}
	_ := exec(cmd: cmd, reset: true, retry: args.retry, retry_timeout: 0, silent: true) or {
		// println(err.code())
		if err.code() == 2 || err.code() == 9999 { // 2 means is timeout from ping, 9999 means timout from cmd
			return .timeout
		}
		if err.code() == 68 { // means we don;t know the hostname its a dns issue
			return .unknownhost
		}
		panic(err)
	}
	return .ok
}

// Returns the ipaddress as known on the public side
// is using resolver4.opendns.com
pub fn ipaddr_pub_get() !string {
	cmd := 'dig @resolver4.opendns.com myip.opendns.com +short'
	ipaddr := exec(cmd: cmd, reset: false, period: 600000)!
	return ipaddr.trim('\n').trim(' \n')
}
