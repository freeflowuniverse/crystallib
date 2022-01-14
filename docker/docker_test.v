import docker
import builder

fn test_docker1() {
	mut engine := docker.new({}) or { panic(err) }
	engine.reset_all()

	// TODO: HOW CAN WE CHECK THE LIST OF IMAGES IS EMPTY?
	// NEXT IS NOT WORKING
	// assert engine.images_list() == []
	// assert engine.containers_list() == []

	// create an ssh enabled alpine container
	// push to threefold docker hub
	// have a default sshkey in, which is known to our docker classes here
	// the following NEW method gets this container with the default SSH key understood in node
	mut container := engine.builder_container_get()
	container.start()

	mut node := container.node_get()

	mut res := node.execute('ls /')
	// do some assert test

	// check assert that there is 1 container in engine.containers_list()

	println(container)

	// NOW DO SOME MORE TESTS,

	// engine.node = builder.node_new(name: 'test')
	println(engine.images_list())
	panic('A')
	// mut containers := engine.containers_list()
	// mut container := containers[0]
	// println(container)
	// container.start()
	// mut engine2 := DockerEngine<ExecutorLocal>{}
	// engine2.executor.name = "aaa"
	// println(engine2.images_list())
	// mut engine := get(Executor(ExecutorSSH{}))
	// println(engine)
	// println(engine.images_list())
	// mut engine2 := get(ExecutorLocal{})
	// println(engine2.images_list())
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
// 	// println(engine.images_list())
// 	mut containers := engine.containers_list()
// 	println(containers)
// 	mut container := containers[0]
// 	println(container)
// 	container.start() or {panic(err)}
// }
