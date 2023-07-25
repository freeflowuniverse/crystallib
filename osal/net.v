module osal

// TODO: ping

/*
// return the ipaddress as known on the public side
// is using resolver4.opendns.com
pub fn (mut o Osal) ipaddr_pub_get() !string {
	// TODO: rewrite using without Node, cache in redis
	if !o.done_exists('ipaddr') {
		cmd := 'dig @resolver4.opendns.com myip.opendns.com +short'
		res := exec(cmd)!
		o.done_set('ipaddr', res.trim('\n').trim(' \n'))!
	}
	mut ipaddr := o.done_get('ipaddr') or { return 'Error: ipaddr is none' }
	return ipaddr.trim('\n').trim(' \n')
}
*/
