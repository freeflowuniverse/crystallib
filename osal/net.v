module osal

// TODO: ping

[params]
pub struct PingArgs {
pub mut:
	address string [required]
	count u8 = 1 // the ping is successful if it got count amount of replies from the other side
	timeout u16 = 5 // the time in which the other side should respond in seconds
}

pub fn (mut o Osal) ping(args PingArgs) ! {
	cmd := "ping -c ${args.count} -w ${args.timeout} ${args.address}"
	_ := o.exec(cmd: cmd, reset: true, retry_max:0, retry_timeout: 0)!
}


// Returns the ipaddress as known on the public side
// is using resolver4.opendns.com
pub fn (mut o Osal) ipaddr_pub_get() !string {
	cmd := 'dig @resolver4.opendns.com myip.opendns.com +short'
	ipaddr := o.exec(cmd: cmd, reset: false, period: 600000)!
	return ipaddr.trim('\n').trim(' \n')
}

