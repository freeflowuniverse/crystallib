module vdcclient
import net.http
import json

pub struct Client {
	url string
	password string
}

pub fn (client Client) get_vdc_info() VDC {
	body := json.encode(Body{client.password})
	full_url := client.url + "/api/controller/vdc"

	response := http.post_json(full_url, body) or {panic("Can't post your request with error $err")}
	return json.decode(VDC, response.text)
}

pub fn (client Client) list_kubernetes_nodes() []Kubernetes {
	body := json.encode(Body{client.password})
	full_url := client.url + "/api/controller/node/list"

	response := http.post_json(full_url, body) or {panic("Can't post your request with error $err")}
	return json.decode([]Kubernetes, response.text)
}

pub fn (client Client) add_kubernetes_node(flavor string) []int {
	body := json.encode(AddKubernetesBody{password: client.password, flavor: flavor})
	full_url := client.url + "/api/controller/node/add"

	response := http.post_json(full_url, body) or {panic("Can't post your request with error $err")}
	return json.decode([]int, response.text)
}

pub fn (client Client) delete_kubernetes_node(wid string) {
	body := json.encode(DeleteBody{password: client.password, wid: wid})
	full_url := client.url + "/api/controller/node/delete"

	response := http.post_json(full_url, body) or {panic("Can't post your request with error $err")}
}

pub fn (client Client) list_storage_nodes() []ZDB {
	body := json.encode(Body{client.password})
	full_url := client.url + "/api/controller/zdb/list"

	response := http.post_json(full_url, body) or {panic("Can't post your request with error $err")}
	return json.decode([]ZDB, response.text)
}

pub fn (client Client) add_storage_node(capacity int, farm string) []int {
	body := json.encode(AddStorageBody{
		password: client.password 
		capacity: capacity
		farm: farm
	})
	full_url := client.url + "/api/controller/zdb/add"

	response := http.post_json(full_url, body) or {panic("Can't post your request with error $err")}
	return json.decode([]int, response.text)
}

pub fn (client Client) delete_storage_node(wid string) {
	body := json.encode(DeleteBody{password: client.password, wid: wid})
	full_url := client.url + "/api/controller/zdb/delete"

	response := http.post_json(full_url, body) or {panic("Can't post your request with error $err")}
}

pub fn (client Client) get_vdc_wallet() Wallet {
	body := json.encode(Body{client.password})
	full_url := client.url + "/api/controller/wallet"

	response := http.post_json(full_url, body) or {panic("Can't post your request with error $err")}
	return json.decode(Wallet, response.text)
}

pub fn (client Client) get_used_pools() []Pool {
	body := json.encode(Body{client.password})
	full_url := client.url + "/api/controller/pools"

	response := http.post_json(full_url, body) or {panic("Can't post your request with error $err")}
	return json.decode([]Pool, response.text)
}

pub fn (client Client) get_alerts(application string) []Alert {
	body := json.encode(AlertBody{
		password: client.password
		application: application
	})
	full_url := client.url + "/api/controller/alerts"

	response := http.post_json(full_url, body) or {panic("Can't post your request with error $err")}
	return json.decode([]Alert, response.text)
}
