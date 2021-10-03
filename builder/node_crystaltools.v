

module builder



pub fn (mut node Node) crystaltools_install() ?{
	println(' - $node.name: install crystaltools')
	if node.done_exists("install_crystaltools"){
		println("    $node.name: was already done")
		return
	}
	node.executor.exec('cd /tmp && curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/install.sh | bash') or {
		return error('Cannot install crystal tools.\n$err')
	}
	node.done_set("install_crystaltools","OK")?
}



