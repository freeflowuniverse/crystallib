import vdcclient

fn setup() vdcclient.Client {
	return vdcclient.Client{
		password: "12345678"
		url: "https://essam-vdcessam.vdcdev.grid.tf/vdc_dashboard"
	}
}

fn test_get_vdc_info() {
	client := setup()
	response := client.get_vdc_info()
	assert response.vdc_name == "vdcessam"
}

fn test_list_kubernetes_nodes() {
	client := setup()
	response := client.list_kubernetes_nodes()
	assert response[0].wid != 0
}

// fn test_add_kubernetes_node() {
// 	client := setup()
// 	response := client.add_kubernetes_node("MEDIUM")
// 	assert response[0].wid != 0
// }

fn test_delete_kubernetes_node() {
	client := setup()
	before_delete := client.list_kubernetes_nodes()
	to_delete := all_nodes[1].wid
	response := client.delete_kubernetes_node(to_delete)
	after_delete := client.list_kubernetes_nodes()

	assert before_delete.len == after_delete.len + 1
}

fn test_list_storage_nodes() {
	client := setup()
	response := client.list_storage_nodes()
	assert response[0].wid != 0
}

// fn test_add_storage_node() {
// 	client := setup()
// 	capacity = 10
// 	farm = ""
// 	response := client.add_storage_node(capacity, farm)
// 	assert response[0].wid != 0
// }

fn test_delete_storage_node() {
	client := setup()
	before_delete := client.list_storage_nodes()
	to_delete := all_nodes[0].wid
	response := client.delete_storage_node(to_delete)
	after_delete := client.list_storage_nodes()

	assert before_delete.len == after_delete.len + 1
}

fn test_get_vdc_wallet() {
	client := setup()
	response := client.get_vdc_wallet()
	assert response.address != ""
}

fn test_get_alerts() {
	client := setup()
	response := client.get_alerts()
	assert response[0].id > 0
}
