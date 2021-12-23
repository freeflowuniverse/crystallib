module twinclient

import threefoldtech.info_specs_grid3.vlang.zos
import json

pub fn (mut tw Client) deploy_kubernetes(payload K8S) ?DeployResponse {
	/*
	Deploy kubernetes workload
		Input:
			- payload (K8S): kubernetes payload
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config
	*/
	payload_encoded := json.encode_pretty(payload)
	return tw.deploy_kubernetes_with_encoded_payload(payload_encoded)
}

pub fn (mut tw Client) deploy_kubernetes_with_encoded_payload(payload_encoded string) ?DeployResponse {
	/*
	Deploy kubernetes workload with encoded payload
		Input:
			- payload (string): kubernetes encoded payload.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config.
	*/
	mut msg := tw.send('twinserver.k8s.deploy', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) get_kubernetes(name string) ?[]zos.Deployment {
	/*
	Get kubernetes info using deployment name
		Input:
			- name (string): Deployment name
		Output:
			- Deployments: List of all zos Deplyments related to kubernets deployment.
	*/
	mut msg := tw.send('twinserver.k8s.get', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]zos.Deployment, response.data) or {}
}

pub fn (mut tw Client) add_worker(worker AddKubernetesNode) ?DeployResponse {
	/*
	Add new worker to a kubernetes deployment
		Input:
			- worker (AddKubernetesNode): AddKubernetesNode object contains new worker info.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config.
	*/
	payload_encoded := json.encode_pretty(worker)
	mut msg := tw.send('twinserver.k8s.add_worker', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) delete_worker(worker_to_delete SingleDelete) ?DeployResponse {
	/*
	Delete worker from a kubernetes deployment
		Input:
			- worker_to_delete (SingleDelete): struct contains name and deployment name.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config.
	*/
	payload_encoded := json.encode_pretty(worker_to_delete)
	mut msg := tw.send('twinserver.k8s.delete_worker', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) update_kubernetes(payload K8S) ?DeployResponse {
	/*
	Update kubernetes with payload.
		Input:
			- payload (K8S): kubernetes instance with modified data.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config
	*/
	payload_encoded := json.encode_pretty(payload)
	return tw.update_kubernetes_with_encoded_payload(payload_encoded)
}

pub fn (mut tw Client) update_kubernetes_with_encoded_payload(payload_encoded string) ?DeployResponse {
	/*
	Get kubernetes info using deployment name.
		Input:
			- payload_encoded (string): encoded payload with modified data.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config
	*/
	mut msg := tw.send('twinserver.k8s.update', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) list_kubernetes() ?[]string {
	/*
	List all kubernetes
		Output:
			- kubernetes: Array of all current kubernetes name for specifc twin.
	*/
	mut msg := tw.send('twinserver.k8s.list', '{}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

pub fn (mut tw Client) delete_kubernetes(name string) ?ContractDeployResponse {
	/*
	Delete deployed kubernetes.
		Input:
			- name (string): kubernetes name.
		Output:
			- response: List of contracts {deleted}.
	*/
	mut msg := tw.send('twinserver.k8s.delete', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}
