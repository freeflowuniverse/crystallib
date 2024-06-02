module docker

import freeflowuniverse.crystallib.ui.console

fn test_docker1() {
	// mut engine := engine_local([]) or { panic(err) }

	// engine.reset_all()!

	// create an ssh enabled alpine container
	// push to threefold docker hub
	// have a default sshkey in, which is known to our docker classes here
	// the following NEW method gets this container with the default SSH key understood in node
	// mut container := engine.container_get('test_container') or {
	// 	panic('Cannot get test container')
	// }
	// container.start()!

	// mut res := node.exec('ls /')!
	// do some assert test

	// check assert that there is 1 container in engine.containers_list()

	// console.print_debug(container)

	// NOW DO SOME MORE TESTS,

	// engine.node = builder.node_new(name: 'test')
	// console.print_debug(engine.images_list() or { []&DockerImage{} })
	// panic('A')
	// mut containers := engine.containers_list()
	// mut container := containers[0]
	// console.print_debug(container)
	// container.start()
	// mut engine2 := DockerEngine<ExecutorLocal>{}
	// engine2.executor.name = "aaa"
	// console.print_debug(engine2.images_list())
	// mut engine := get(Executor(ExecutorSSH{}))
	// console.print_debug(engine)
	// console.print_debug(engine.images_list())
	// mut engine2 := get(ExecutorLocal{})
	// console.print_debug(engine2.images_list())
}

// fn test_remote_docker() {
// 	node := builder.Node{
// 		name: "remote digitalocean",
// 		platform: builder.PlatformType.ubuntu,
// 		executor: builder.ExecutorSSH{
// 			sshkey: "~/.ssh/id_rsa_test",
// 			user: "root",
// 			ipaddr: builder.IPAddress{
// 				addr: "104.236.53.191",
// 				port: builder.Port{
// 					number: 22,
// 					cat: builder.PortType.tcp
// 				},
// 				cat: builder.IpAddressType.ipv4
// 			}
// 		}
// 	}
// 	engine.node = node
// 	// console.print_debug(engine.images_list())
// 	mut containers := engine.containers_list()
// 	console.print_debug(containers)
// 	mut container := containers[0]
// 	console.print_debug(container)
// 	container.start() or {panic(err)}
// }
