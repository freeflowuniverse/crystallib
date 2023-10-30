
module zinit

// this test needs a zinit service already running watching a service named hello, and should be run as sudo
// TODO: create a docker file with zinit running
fn test_stop() {
	st := status('hello')!
	println(st)

	stop('hello')!
	forget('hello')!
	monitor('hello')!
	start('hello')!
	kill('hello', 'sigterm')!

	ls := list()!
	println('zinit list ${ls}')
}
