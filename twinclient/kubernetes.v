module twinclient

import json

// Deploy kubernetes workload
pub fn (mut tw Client) deploy_kubernetes(payload K8S) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.k8s.deploy', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// Get kubernetes deployment info using deployment name
pub fn (mut tw Client) get_kubernetes(name string) ?[]Deployment {
	mut msg := tw.send('twinserver.k8s.get', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]Deployment, response.data) or {}
}

// Add new worker to a kubernetes deployment
pub fn (mut tw Client) add_worker(worker AddKubernetesNode) ?DeployResponse {
	payload_encoded := json.encode_pretty(worker)
	mut msg := tw.send('twinserver.k8s.add_worker', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// Delete worker from a kubernetes deployment
pub fn (mut tw Client) delete_worker(worker_to_delete SingleDelete) ?ContractResponse {
	payload_encoded := json.encode_pretty(worker_to_delete)
	mut msg := tw.send('twinserver.k8s.delete_worker', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ContractResponse, response.data) or {}
}

// Update deployed kubernetes with updated payload.
pub fn (mut tw Client) update_kubernetes(payload K8S) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.k8s.update', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// List all my kubernetes deployments
pub fn (mut tw Client) list_kubernetes() ?[]string {
	mut msg := tw.send('twinserver.k8s.list', '{}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

// Delete deployed kubernetes using deployment name
pub fn (mut tw Client) delete_kubernetes(name string) ?ContractResponse {
	mut msg := tw.send('twinserver.k8s.delete', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ContractResponse, response.data) or {}
}
