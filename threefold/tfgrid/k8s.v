module tfgrid

pub fn (mut client TFGridClient) k8s_deploy(cluster K8sCluster) !K8sClusterResult {
	retqueue := client.rpc.call[K8sCluster]('tfgrid.k8s.deploy', cluster)!
	return client.rpc.result[K8sClusterResult](500000, retqueue)!
}

pub fn (mut client TFGridClient) k8s_delete(name string) ! {
	retqueue := client.rpc.call[string]('tfgrid.k8s.delete', name)!
	client.rpc.result[string](500000, retqueue)!
}

pub fn (mut client TFGridClient) k8s_get(name string) !K8sClusterResult {
	retqueue := client.rpc.call[string]('tfgrid.k8s.get', name)!
	return client.rpc.result[K8sClusterResult](500000, retqueue)!
}

pub fn (mut client TFGridClient) k8s_add_node(add_node AddK8sNode) !K8sClusterResult {
	retqueue := client.rpc.call[AddK8sNode]('tfgrid.k8s.node.add', add_node)!
	return client.rpc.result[K8sClusterResult](500000, retqueue)!
}

pub fn (mut client TFGridClient) k8s_remove_node(remove_node RemoveK8sNode) !K8sClusterResult {
	retqueue := client.rpc.call[RemoveK8sNode]('tfgrid.k8s.node.remove', remove_node)!
	return client.rpc.result[K8sClusterResult](500000, retqueue)!
}
