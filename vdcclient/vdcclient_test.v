import vdcclient

fn setup() vdcclient.Client {
	return vdcclient.Client{
		vdcname: "ADD_YOUR_VDC_NAME"
		password: "ADD_YOUR_VDC_PASSWORD"
		url: "ADD_YOUR_VDC_URL_INCLUDING_vdc_dashboard_PART"
	}
}

fn test_get_vdc_info() {
	client := setup()
	println("************ TEST01_GET_VDC_INFO ************")
	response, status_code := client.get_vdc_info()
	println(response)
	assert status_code == 200
	assert response.vdc_name == client.vdcname
}

fn test_list_kubernetes_nodes() {
	client := setup()
	println("************ TEST02_LIST_KUBERNETES_NODES ************")
	response, status_code := client.list_kubernetes_nodes()
	println(response)
	assert status_code == 200
	assert response[0].wid > 0
}

fn test_add_kubernetes_node() {
	client := setup()
	println("************ TEST03_ADD_KUBERNETES_NODE ************")
	response, status_code := client.add_kubernetes_node("MEDIUM")
	println(response)
	assert status_code == 200
	assert response[0] > 0
}

fn test_delete_kubernetes_node() {
	client := setup()
	println("************ TEST04_DELETE_KUBERNETES_NODE ************")
	before_delete, _ := client.list_kubernetes_nodes()
	// to_delete := before_delete[before_delete.len -1].wid
	to_delete := 47049
	response, status_code := client.delete_kubernetes_node(to_delete)
	after_delete, _ := client.list_kubernetes_nodes()
	println(response)
	assert status_code == 200
	assert before_delete.len == after_delete.len + 1
}

fn test_list_storage_nodes() {
	client := setup()
	println("************ TEST05_LIST_STORAGE_NODES ************")
	response, status_code := client.list_storage_nodes()
	println(response)
	assert status_code == 200
	if response.len > 0 {
		assert response[0].wid > 0
	}
}

fn test_add_storage_node() {
	client := setup()
	println("************ TEST06_ADD_STORAGE_NODE ************")
	capacity := 10
	farm := ""
	response, status_code := client.add_storage_node(capacity, farm)
	println(response)
	assert status_code == 200
	assert response[0] > 0
}

fn test_delete_storage_node() {
	client := setup()
	println("************ TEST07_DELETE_STORAGE_NODE ************")
	before_delete, _ := client.list_storage_nodes()
	to_delete := before_delete[before_delete.len - 1].wid
	response, status_code := client.delete_storage_node(to_delete)
	after_delete, _ := client.list_storage_nodes()
	println(response)
	assert status_code == 200
	assert before_delete.len == after_delete.len + 1
}

fn test_get_vdc_wallet() {
	client := setup()
	println("************ TEST08_GET_VDC_WALLET ************")
	response, status_code := client.get_vdc_wallet()
	println(response)
	assert status_code == 200
	assert response.address != ""
}

fn test_get_vdc_used_pools() {
	client := setup()
	println("************ TEST09_GET_USED_POOLS ************")
	response, status_code := client.get_used_pools()
	println(response)
	assert status_code == 200
	assert response[0].pool_id > 0
}

fn test_get_alerts() {
	client := setup()
	println("************ TEST10_GET_VDC_ALERTS ************")
	application := "REPLACE_WITH YOUR_APP OR LET IT EMPTY"
	response, status_code := client.get_alerts(application)
	println(response)
	assert status_code == 200
}


fn test_get_kubeconfig() {
	client := setup()
	println("************ TEST11_GET_KUBECONFIG ************")
	response, status_code := client.get_kubeconfig()
	println("Request Status: $status_code")
	println(response)
	assert status_code == 200
}

fn test_get_zstor_config() {
	client := setup()
	println("************ TEST12_GET_ZSTOR-CONFIG ************")
	ip_version := 4 // 4 or 6
	response, status_code := client.get_zstor_config(ip_version)
	println(response)
	assert status_code == 200
}

fn test_get_status() {
	client := setup()
	println("************ TEST13_GET_STATUS ************")
	response, status_code := client.get_status()
	println(response)
	assert status_code == 200
	assert response.running
}
