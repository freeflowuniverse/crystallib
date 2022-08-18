module twinclient2

import json

// Deploy kubernetes workload
pub fn (mut tw TwinClient) deploy_kubernetes(payload K8S) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('k8s.deploy', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// Get kubernetes deployment info using deployment name
pub fn (mut tw TwinClient) get_kubernetes(name string) ?[]Deployment {
	response := tw.send('k8s.get', '{"name": "$name"}')?

	return json.decode([]Deployment, response.data) or {}
}

// Add new worker to a kubernetes deployment
pub fn (mut tw TwinClient) add_worker(worker AddKubernetesNode) ?DeployResponse {
	payload_encoded := json.encode_pretty(worker)
	response := tw.send('k8s.add_worker', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// Delete worker from a kubernetes deployment
pub fn (mut tw TwinClient) delete_worker(worker_to_delete SingleDelete) ?ContractResponse {
	payload_encoded := json.encode_pretty(worker_to_delete)
	response := tw.send('k8s.delete_worker', payload_encoded)?

	return json.decode(ContractResponse, response.data) or {}
}

// Update deployed kubernetes with updated payload.
pub fn (mut tw TwinClient) update_kubernetes(payload K8S) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('k8s.update', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// List all my kubernetes deployments
pub fn (mut tw TwinClient) list_kubernetes() ?[]string {
	response := tw.send('k8s.list', '{}')?

	return json.decode([]string, response.data) or {}
}

// Delete deployed kubernetes using deployment name
pub fn (mut tw TwinClient) delete_kubernetes(name string) ?ContractResponse {
	response := tw.send('k8s.delete', '{"name": "$name"}')?

	return json.decode(ContractResponse, response.data) or {}
}
