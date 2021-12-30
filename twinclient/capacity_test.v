module twinclient

import os.cmdline
import os

struct CapacityTestData {
	page_payload PagePayload
	filters      FilterOptions
	farm_name    string
	farm_id      u32
	node_id      u32
}

fn setup_capacity_test() (Client, CapacityTestData) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_contracts_test with error: $err')
	}

	data := CapacityTestData{
		page_payload: PagePayload{}
		filters: FilterOptions{
			sru: 10
		}
		farm_name: 'Freefarm'
		farm_id: 1
		node_id: 5
	}
	return client, data
}

fn t0_get_farms(mut client Client, data CapacityTestData) {
	println('--------- Get Farms (limited wit max_size) ---------')
	farms := client.get_farms(data.page_payload) or { panic(err) }
	assert farms.len <= data.page_payload.max_result
	println('Found $farms.len farms in page $data.page_payload.page')
}

fn t1_get_nodes(mut client Client, data CapacityTestData) {
	println('--------- Get Nodes (limited wit max_size) ---------')
	nodes := client.get_nodes(data.page_payload) or { panic(err) }
	assert nodes.len <= data.page_payload.max_result
	println('Found $nodes.len nodes in page $data.page_payload.page')
}

fn t2_get_all_farms(mut client Client, data CapacityTestData) {
	println('--------- Get All Farms ---------')
	all_farms := client.get_all_farms() or { panic(err) }
	println('Found $all_farms.len farms')
}

fn t3_get_all_nodes(mut client Client, data CapacityTestData) {
	println('--------- Get All Nodes ---------')
	all_nodes := client.get_all_nodes() or { panic(err) }
	println('Found $all_nodes.len farms')
}

fn t4_filter_nodes(mut client Client, data CapacityTestData) {
	println('--------- Filter Nodes by SRU ---------')
	error_msg := "Couldn't find a valid node for these options"
	filtered_nodes := client.filter_nodes(data.filters) or { panic(err) }
	if filtered_nodes.len > 0 {
		println('Found $filtered_nodes.len nodes')
	} else {
		println(error_msg)
	}
}

fn t5_check_farm_has_free_public_ips(mut client Client, data CapacityTestData) {
	println('--------- Check PublicIP in Farm ---------')
	is_free := client.check_farm_has_free_public_ips(data.farm_id) or { panic(err) }
	println('Farm #$data.farm_id has free public ip:: $is_free')
}

fn t6_get_nodes_by_farm_id(mut client Client, data CapacityTestData) {
	println('--------- Get Nodes in Farm ---------')
	farm_nodes := client.get_nodes_by_farm_id(data.farm_id) or { panic(err) }
	println(farm_nodes)
}

fn t7_get_node_free_resources(mut client Client, data CapacityTestData) {
	println('--------- Get Free Resources in Node ---------')
	resources := client.get_node_free_resources(data.node_id) or { panic(err) }
	println('Node #$data.node_id resources:: $resources')
}

fn t8_get_farm_id_from_farm_name(mut client Client, data CapacityTestData) {
	println('--------- Get Farm Id From Farm Name ---------')
	farm_id := client.get_farm_id_from_farm_name(data.farm_name) or { panic(err) }
	println('$data.farm_name id:: $farm_id')
}

pub fn test_capacity() {
	mut client, data := setup_capacity_test()

	mut cmd_test := cmdline.options_after(os.args, ['--test', '-t'])
	if cmd_test.len == 0 {
		cmd_test << 'all'
	}

	test_cases := ['t0_get_farms', 't1_get_nodes', 't2_get_all_farms', 't3_get_all_nodes',
		't4_filter_nodes', 't5_check_farm_has_free_public_ips', 't6_get_nodes_by_farm_id',
		't7_get_node_free_resources', 't8_get_farm_id_from_farm_name']

	for tc in cmd_test {
		match tc {
			't0_get_farms' {
				t0_get_farms(mut client, data)
			}
			't1_get_nodes' {
				t1_get_nodes(mut client, data)
			}
			't2_get_all_farms' {
				t2_get_all_farms(mut client, data)
			}
			't3_get_all_nodes' {
				t3_get_all_nodes(mut client, data)
			}
			't4_filter_nodes' {
				t4_filter_nodes(mut client, data)
			}
			't5_check_farm_has_free_public_ips' {
				t5_check_farm_has_free_public_ips(mut client, data)
			}
			't6_get_nodes_by_farm_id' {
				t6_get_nodes_by_farm_id(mut client, data)
			}
			't7_get_node_free_resources' {
				t7_get_node_free_resources(mut client, data)
			}
			't8_get_farm_id_from_farm_name' {
				t8_get_farm_id_from_farm_name(mut client, data)
			}
			'all' {
				t0_get_farms(mut client, data)
				t1_get_nodes(mut client, data)
				t2_get_all_farms(mut client, data)
				t3_get_all_nodes(mut client, data)
				t4_filter_nodes(mut client, data)
				t5_check_farm_has_free_public_ips(mut client, data)
				t6_get_nodes_by_farm_id(mut client, data)
				t7_get_node_free_resources(mut client, data)
				t8_get_farm_id_from_farm_name(mut client, data)
			}
			else {
				println('Available test case:\n$test_cases, or all to run all test cases')
			}
		}
	}
}
