module builder

// hello_test.v
fn test_ping() {
	mut addr := IPAddress{
		addr: '127.0.0.1'
		port: Port{
			number: 9001
			cat: PortType.tcp
		}
		cat: IpAddressType.ipv4
	}
	addr.ping(ExecutorLocal{})
}
