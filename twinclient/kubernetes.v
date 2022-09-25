module twinclient

import json


// Deploy kubernetes workload
pub fn (mut client TwinClient) kubernetes_deploy(payload K8SModel) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := client.transport.send('k8s.deploy', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Get kubernetes deployment info using deployment name
pub fn (mut client TwinClient) kubernetes_get(name string) ?[]Deployment {
	response := client.transport.send('k8s.get', json.encode({"name": name}))?

	return json.decode([]Deployment, response.data)
}

// Add new worker to a kubernetes deployment
pub fn (mut client TwinClient) kubernetes_add_worker(worker AddKubernetesNode) ?DeployResponse {
	payload_encoded := json.encode_pretty(worker)
	response := client.transport.send('k8s.add_worker', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Delete worker from a kubernetes deployment
pub fn (mut client TwinClient) kubernetes_delete_worker(worker_to_delete SingleDelete) ?ContractResponse {
	payload_encoded := json.encode_pretty(worker_to_delete)
	response := client.transport.send('k8s.delete_worker', payload_encoded)?

	return json.decode(ContractResponse, response.data)
}

// Update deployed kubernetes with updated payload.
pub fn (mut client TwinClient) kubernetes_update(payload K8SModel) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := client.transport.send('k8s.update', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// List all my kubernetes deployments
pub fn (mut client TwinClient) kubernetes_list() ?[]string {
	response := client.transport.send('k8s.list', '{}')?

	return json.decode([]string, response.data)
}

// Delete deployed kubernetes using deployment name
pub fn (mut client TwinClient) kubernetes_delete(name string) ?ContractResponse {
	response := client.transport.send('k8s.delete', json.encode({"name": name}))?

	return json.decode(ContractResponse, response.data)
}
