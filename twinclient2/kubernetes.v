module twinclient2

import json


fn new_k8s(mut client TwinClient) K8S {
	// Initialize new tfchain.
	return K8S{
		client: unsafe {client}
	}
}

// Deploy kubernetes workload
pub fn (mut k8s K8S) deploy(payload K8SModel) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := k8s.client.send('k8s.deploy', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Get kubernetes deployment info using deployment name
pub fn (mut k8s K8S) get(name string) ?[]Deployment {
	response := k8s.client.send('k8s.get', json.encode({"name": name}))?

	return json.decode([]Deployment, response.data)
}

// Add new worker to a kubernetes deployment
pub fn (mut k8s K8S) add_worker(worker AddKubernetesNode) ?DeployResponse {
	payload_encoded := json.encode_pretty(worker)
	response := k8s.client.send('k8s.add_worker', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Delete worker from a kubernetes deployment
pub fn (mut k8s K8S) delete_worker(worker_to_delete SingleDelete) ?ContractResponse {
	payload_encoded := json.encode_pretty(worker_to_delete)
	response := k8s.client.send('k8s.delete_worker', payload_encoded)?

	return json.decode(ContractResponse, response.data)
}

// Update deployed kubernetes with updated payload.
pub fn (mut k8s K8S) update(payload K8SModel) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := k8s.client.send('k8s.update', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// List all my kubernetes deployments
pub fn (mut k8s K8S) list() ?[]string {
	response := k8s.client.send('k8s.list', '{}')?

	return json.decode([]string, response.data)
}

// Delete deployed kubernetes using deployment name
pub fn (mut k8s K8S) delete(name string) ?ContractResponse {
	response := k8s.client.send('k8s.delete', json.encode({"name": name}))?

	return json.decode(ContractResponse, response.data)
}
