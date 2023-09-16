module tmux

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.tmux

// uses single tmux instance for all tests
__global (
	tmux Tmux
)

fn init() {
	tmux = get_remote('185.69.166.152')!

	// reset tmux for tests
	if tmux.is_running() {
		tmux.stop() or { panic('Cannot stop tmux') }
	}
}

fn testsuite_end() {
	if tmux.is_running() {
		tmux.stop()!
	}
}

fn test_window_new() {
	tmux.start() or { panic("can't start tmux: ${err}") }

	// test window new with only name arg
	window_args := WindowArgs{
		name: 'TestWindow'
	}

	assert !tmux.sessions.keys().contains('main')

	mut window := tmux.window_new(window_args) or { panic("Can't create new window: ${err}") }
	assert tmux.sessions.keys().contains('main')
	window.delete() or { panic('Cant delete window') }
}

// // tests creating duplicate windows
// fn test_window_new0() {

// 	mut builder := builder.new()
// 	mut node_ssh := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!
// 	installer := tmux.get_install(mut node_ssh) or { panic("could not install tmux to node: $err") }

// 	mut tmux := Tmux {
// 		node: node_ssh
// 	}

// 	window_args := WindowArgs {
// 		name: 'TestWindow0'
// 	}

// 	// println(tmux)
// 	mut window := tmux.window_new(window_args) or {
// 		panic("Can't create new window: $err")
// 	}
// 	assert tmux.sessions.keys().contains('main')
// 	mut window_dup := tmux.window_new(window_args) or {
// 		panic("Can't create new window: $err")
// 	}
// 	println(node_ssh.exec('tmux ls') or { panic("fail:$err")})
// 	window.delete() or { panic("Cant delete window") }
// 	// println(tmux)
// }
