import twinclient

struct GatewayTestData {
	fqdn twinclient.GatewayFQDN
	name twinclient.GatewayName
}

fn setup_gateway_test() (twinclient.Client, GatewayTestData) {
	redis_server := 'localhost:6379'
	twin_id := 133
	mut client := twinclient.init(redis_server, twin_id) or {
		panic('Fail in setup_gateway_test with error: $err')
	}

	data := GatewayTestData{
		fqdn: twinclient.GatewayFQDN{
			name: 'test1fqdn'
			node_id: 8
			fqdn: 'test1.dev.gridtesting.xyz'
			tls_passthrough: false
			backends: ['http://[201:e709:df8b:b04:6125:1ced:c211:a404]:8080']
		}
		name: twinclient.GatewayName{
			name: 'testname1'
			node_id: 8
			tls_passthrough: false
			backends: ['http://[201:e709:df8b:b04:6125:1ced:c211:a404]:8080']
		}
	}
	return client, data
}

pub fn test_deploy_gateway_fqdn() {
	mut client, data := setup_gateway_test()

	println('------------- Deploy FQDN Gateway -------------')
	new_fqdn := client.deploy_gateway_fqdn(data.fqdn) or { panic(err) }
	defer {
		client.delete_gateway_fqdn(data.fqdn.name) or { panic(err) }
	}

	assert new_fqdn.contracts.created.len == 1
	assert new_fqdn.contracts.updated.len == 0
	assert new_fqdn.contracts.deleted.len == 0
}

pub fn test_deploy_gateway_name() {
	mut client, data := setup_gateway_test()

	println('------------- Deploy Name Gateway -------------')
	new_name := client.deploy_gateway_name(data.name) or { panic(err) }
	defer {
		client.delete_gateway_name(data.name.name) or { panic(err) }
	}

	assert new_name.contracts.created.len == 1
	assert new_name.contracts.updated.len == 0
	assert new_name.contracts.deleted.len == 0
}
