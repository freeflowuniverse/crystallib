import freeflowuniverse.crystallib.builder

// hello_test.v
fn test_ping() {
	mut addr := builder.IPAddress{
		addr: '127.0.0.1'
	}
	addr.ping(ExecutorLocal{})
}
