module osal


fn test_ipaddr_pub_get() {
	mut o := new()!
	ipaddr := o.ipaddr_pub_get()!
	assert ipaddr != ""
}