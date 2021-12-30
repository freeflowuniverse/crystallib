module twinclient

import os.cmdline
import os

struct GatewayTestData {
	fqdn GatewayFQDN
	name GatewayName
}

fn setup_gateway_test() (Client, GatewayTestData) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_gateway_test with error: $err')
	}

	data := GatewayTestData{
		fqdn: GatewayFQDN{
			name: 'essamfqdn'
			node_id: 8
			fqdn: 'essam.dev.gridtesting.xyz'
			tls_passthrough: false
			backends: ['http://[201:e709:df8b:b04:6125:1ced:c211:a404]:8080']
		}
		name: GatewayName{
			name: 'essam73test'
			node_id: 8
			tls_passthrough: false
			backends: ['http://[201:e709:df8b:b04:6125:1ced:c211:a404]:8080']
		}
	}
	return client, data
}

fn t0_deploy_gateway_fqdn(mut client Client, data GatewayTestData) {
	println('--------- Deploy FQDN GATEWAY ---------')
	new_fqdn := client.deploy_gateway_fqdn(data.fqdn) or { panic(err) }
	println(new_fqdn)
}

fn t1_deploy_gateway_name(mut client Client, data GatewayTestData) {
	println('--------- Deploy Name GATEWAY ---------')
	new_name := client.deploy_gateway_name(data.name) or { panic(err) }
	println(new_name)
}

fn t2_get_gateway_fqdn(mut client Client, data GatewayTestData) {
	println('--------- Get FQDN GATEWAY ---------')
	get_fqdn := client.get_gateway_fqdn(data.fqdn.name) or { panic(err) }
	println(get_fqdn)
}

fn t3_get_gateway_name(mut client Client, data GatewayTestData) {
	println('--------- Get Name GATEWAY ---------')
	get_name := client.get_gateway_name(data.name.name) or { panic(err) }
	println(get_name)
}

fn t4_delete_gateway_fqdn(mut client Client, data GatewayTestData) {
	println('--------- Delete FQDN GATEWAY ---------')
	deleted_id := client.delete_gateway_fqdn(data.fqdn.name) or { panic(err) }
	println(deleted_id)
}

fn t5_delete_gateway_name(mut client Client, data GatewayTestData) {
	println('--------- Delete Name GATEWAY ---------')
	deleted_id := client.delete_gateway_name(data.name.name) or { panic(err) }
	println(deleted_id)
}

pub fn test_gateways() {
	mut client, data := setup_gateway_test()
	mut cmd_test := cmdline.options_after(os.args, ['--test', '-t'])
	if cmd_test.len == 0 {
		cmd_test << 'all'
	}

	test_cases := ['t0_deploy_gateway_fqdn', 't1_deploy_gateway_name', 't2_get_gateway_fqdn',
		't3_get_gateway_name', 't4_delete_gateway_fqdn', 't5_delete_gateway_name']
	for tc in cmd_test {
		match tc {
			't0_deploy_gateway_fqdn' {
				t0_deploy_gateway_fqdn(mut client, data)
			}
			't1_deploy_gateway_name' {
				t1_deploy_gateway_name(mut client, data)
			}
			't2_get_gateway_fqdn' {
				t2_get_gateway_fqdn(mut client, data)
			}
			't3_get_gateway_name' {
				t3_get_gateway_name(mut client, data)
			}
			't4_delete_gateway_fqdn' {
				t4_delete_gateway_fqdn(mut client, data)
			}
			't5_delete_gateway_name' {
				t5_delete_gateway_name(mut client, data)
			}
			'all' {
				t0_deploy_gateway_fqdn(mut client, data)
				t1_deploy_gateway_name(mut client, data)
				t2_get_gateway_fqdn(mut client, data)
				t3_get_gateway_name(mut client, data)
				t4_delete_gateway_fqdn(mut client, data)
				t5_delete_gateway_name(mut client, data)
			}
			else {
				println('Available test case:\n$test_cases, or all to run all test cases')
			}
		}
	}
}
