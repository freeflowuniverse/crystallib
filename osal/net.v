module osal

// TODO: ping


// return the ipaddress as known on the public side
// is using resolver4.opendns.com
pub fn (mut o Osal) ipaddr_pub_get() !string {
	cmd := 'dig @resolver4.opendns.com myip.opendns.com +short'
	ipaddr := o.exec(cmd: cmd, reset: false, period: 600000)!
	return ipaddr.trim('\n').trim(' \n')
}

