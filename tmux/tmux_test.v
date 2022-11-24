module tmux

import os
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.installers.tmux

const testpath = os.dir(@FILE) + '/testdata'

fn testsuite_begin() {
	mut builder := builder.new()
	mut node := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!
	mut tmux := Tmux{
		node: node
	}
	if tmux.is_running() {
		tmux.stop()!
	}
}

fn testsuite_end() {
	mut builder := builder.new()
	mut node := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!
	mut tmux := Tmux{
		node: node
	}
	if tmux.is_running() {
		tmux.stop()!
	}
}

fn test_start() ! {
	mut builder := builder.new()
	mut node_ssh := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!
	tmux.get_install(mut node_ssh)!
	mut tmux := Tmux{
		node: node_ssh
	}

	// test server is running after start()
	tmux.start() or { panic('cannot start tmux: $err') }
	mut tmux_ls := node_ssh.exec('tmux ls') or { panic('Cannot execute tmux ls: $err') }
	assert tmux_ls.contains('init: 1 windows')
	tmux.stop() or { panic('cannot stop tmux: $err') }
}

fn test_stop() ! {
	mut builder := builder.new()
	mut node_ssh := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!
	tmux.get_install(mut node_ssh)!
	mut tmux := Tmux{
		node: node_ssh
	}

	// test server is running after start()
	tmux.start() or { panic('cannot start tmux: $err') }
	assert tmux.is_running()
	tmux.stop() or { panic('cannot stop tmux: $err') }
	assert !tmux.is_running()
}

fn test_windows_get() ! {
	mut builder := builder.new()
	mut node_ssh := builder.node_new(
		name: 'test'
		ipaddr: '185.69.166.152'
		debug: true
	)!
	mut tmux := Tmux{
		node: node_ssh
	}

	// test windows_get when no windows are running
	tmux.start()!
	mut windows := tmux.windows_get()
	assert windows.len == 0

	tmux.window_new(WindowArgs{ name: 'testwindow' })!
	windows = tmux.windows_get()
	assert windows['testwindow'].name == 'testwindow'
	assert windows['testwindow'].active
	unsafe {
		assert windows.keys().contains('testwindow')
	}
	tmux.stop()!
}

fn test_tmux_window() {
	res := os.execute('${os.quoted_path(@VEXE)} $testpath/tmux_window_test.v')
	// assert res.exit_code == 1
	// assert res.output.contains('other_test.v does not exist')
}


// TODO: fix test
// fn test_scan_add() ! {
// 	println("-----Testing scan_add------")
// 	mut builder := builder.new()
// 	mut node_ssh := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!
// 	mut tmux := Tmux { node: node_ssh }
// 	windows := tmux.scan_add("line")!
// }

// TODO: fix test
// fn test_scan() ! {
// 	println('-----Testing scan------')
// 	mut builder := builder.new()
// 	mut node_ssh := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!
// 	mut tmux := Tmux{
// 		node: node_ssh
// 	}
// 	tmux.start()!
	
// 	// test scan with empty tmux
// 	mut windows := tmux.windows_get()
// 	unsafe {
// 		assert windows.keys().len == 0
// 	}
// 	windows = tmux.scan()!
// 	unsafe {
// 		assert windows.keys().len == 0
// 	}

// 	// test scan with window in struct but not in tmux
// 	// mocking a failed command to see if scan identifies
// 	tmux.sessions['init'].windows['test'] = &Window{
// 		session: tmux.sessions['init']
// 		name: 'test'
// 	}
// 	mut new_windows := tmux.windows_get()
// 	panic('new windows ${new_windows.keys()}')
// 	unsafe {
// 		assert new_windows.keys().len == 1
// 	}
// 	new_windows = tmux.scan()!
// 	tmux.stop()!
// }
