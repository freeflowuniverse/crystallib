module builder

// test the creation of a node
fn test_node_local_basic1() {
	n := node.node_get({}) or { panic(err) }
	res := n.executor.execute('ls /')
	println(res)
	panic('SSS')
}

// // test the creation of a node
// fn test_node_ssh_basic1() {
// 	n := node_get(
// 		ipaddr: '127.0.0.1'
// 		}
// 	)or {panic(err)}
// }
