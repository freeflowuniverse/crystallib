module twinclient

struct GatewayTestData{
	fqdn GatewayFQDN
	name GatewayName
}

pub fn setup_gateway_test() (Client, GatewayTestData) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_gateway_test with error: $err')
	}

	data := GatewayTestData{
		fqdn: GatewayFQDN{name:"essamfqdn", node_id:5, fqdn:"remote.omar.grid.tf", tls_passthrough:false, backends:["http://[69.164.223.208]:80"]}
		name: GatewayName{name:"essam", node_id:5, tls_passthrough: true, backends:["http://[69.164.223.208]:80"]}
	}
	return client, data
}

pub fn test_deploy_gateway_fqdn() {
	mut client, data := setup_gateway_test()

	println('--------- Deploy FQDN GATEWAY ---------')
	new_fqdn := client.deploy_gateway_fqdn(data.fqdn) or { panic(err) }
	println(new_fqdn)	
}

pub fn test_deploy_gateway_name() {
	mut client, data := setup_gateway_test()

	println('--------- Deploy Name GATEWAY ---------')
	new_name := client.deploy_gateway_name(data.name) or { panic(err) }
	println(new_name)
}

pub fn test_get_gateway_fqdn() {
	mut client, data := setup_gateway_test()

	println('--------- Get FQDN GATEWAY ---------')
	client.get_gateway_fqdn(data.fqdn.name) or { panic(err) }
	// println(new_fqdn)
}

pub fn test_get_gateway_name() {
	mut client, data := setup_gateway_test()

	println('--------- Get Name GATEWAY ---------')
	client.get_gateway_name(data.name.name) or { panic(err) }
	// println(new_name)
}

pub fn test_delete_gateway_fqdn() {
	mut client, data := setup_gateway_test()

	println('--------- Delete FQDN GATEWAY ---------')
	client.delete_gateway_fqdn(data.fqdn.name) or { panic(err) }
	// println(new_fqdn)
}

pub fn test_delete_gateway_name() {
	mut client, data := setup_gateway_test()

	println('--------- Delete Name GATEWAY ---------')
	client.delete_gateway_name(data.name.name) or { panic(err) }
	// println(new_name)
}

