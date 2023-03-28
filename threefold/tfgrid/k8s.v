module tfgrid

import json

pub fn (mut client TFGridClient) k8s_deploy(cluster K8sCluster) !K8sClusterResult {
	payload := json.encode_pretty(cluster)
	res := client.rpc.call(cmd: 'k8s.deploy', data: payload)!
	return json.decode(K8sClusterResult, res)
}

pub fn (mut client TFGridClient) k8s_delete(name string) ! {
	client.rpc.call(cmd: 'k8s.delete', data: name)!
}

pub fn (mut client TFGridClient) k8s_get(name string) !K8sClusterResult {
	res := client.rpc.call(cmd: 'k8s.get', data: name)!
	return json.decode(K8sClusterResult, res)
}

pub fn (mut client TFGridClient) k8s_add_node(add_node AddK8sNode) !K8sClusterResult {
	payload := json.encode_pretty(add_node)
	res := client.rpc.call(cmd: 'k8s.node.add', data: payload)!
	return json.decode(K8sClusterResult, res)
}

pub fn (mut client TFGridClient) k8s_remove_node(remove_node RemoveK8sNode) !K8sClusterResult {
	payload := json.encode_pretty(remove_node)
	res := client.rpc.call(cmd: 'k8s.node.remove', data: payload)!
	return json.decode(K8sClusterResult, res)
}