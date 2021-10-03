

module builder



pub fn (mut node Node) node_install_docker_swarm() ?{
	node.platform_prepare()?
	node.crystaltools_install()?

}



//specify which node is the master
pub fn (mut node Node) node_install_docker_swarm_add(node_master Node) ?{
	node.platform_prepare()?
	node.crystaltools_install()?

}
