module twinclient

pub fn test_gateway() {
	// redis_server and twin_dest are const in client.v
	mut tw := init(redis_server, twin_dest) or { panic(err) }

	// Gateway fqdn payload
	fdqn_payload := GatewayFQDN{name:"essamfqdn", node_id:5, fqdn:"remote.omar.grid.tf", tls_passthrough:false, backends:["http://[69.164.223.208]:80"]}
	
	// Create new fqdn gateway
	new_fqdn := tw.deploy_fqdn(fdqn_payload) or { panic(err) }
	println('--------- Deploy FQDN GATEWAY ---------')
	println(new_fqdn)

	// Gateway fqdn payload
	name_payload := GatewayName{name:"essam", node_id:5, tls_passthrough: true, backends:["http://[69.164.223.208]:80"]}
	// Create new name gateway
	new_name := tw.deploy_name(name_payload) or { panic(err) }
	println('--------- Deploy FQDN GATEWAY ---------')
	println(new_fqdn)
}