module tmux

import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.installers.tmux

// fn testsuite_end() {
// 	mut builder := builder.new()
// 	mut node := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!
// }

fn testsuite_begin() {
	mut builder := builder.new()
	mut node := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!
	mut tmux := Tmux { node: node }

	if tmux.is_running()! {
		tmux.stop()!
	}
}

fn test_session_create() {

	mut builder := builder.new()
	mut node_ssh := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!
	installer := tmux.get_install(mut node_ssh) or { panic("could not install tmux to node: $err") }

	mut tmux := Tmux {
		node: node_ssh
	}
	tmux.start() or { panic('cannot start tmux: $err') }

	mut s := Session{
		tmux: &tmux
		windows: map[string]&Window{}
		name: 'testsession'
	}

	mut s2 := Session{
		tmux: &tmux
		windows: map[string]&Window{}
		name: 'testsession2'
	}

	// test testsession exists after session_create
	mut tmux_ls := node_ssh.exec('tmux ls') or { panic("can't exec: $err") }
	assert !tmux_ls.contains("testsession: 1 windows")
	s.create() or  {panic("Cannot create session: $err")}
	tmux_ls = node_ssh.exec('tmux ls') or { panic("can't exec: $err") }
	assert tmux_ls.contains("testsession: 1 windows")

	// test multiple session_create for same tmux
	tmux_ls = node_ssh.exec('tmux ls') or { panic("can't exec: $err") }
	assert !tmux_ls.contains("testsession2: 1 windows")
	s2.create() or  {panic("Cannot create session: $err")}
	tmux_ls = node_ssh.exec('tmux ls') or { panic("can't exec: $err") }
	assert tmux_ls.contains("testsession2: 1 windows")

	// test session_create with duplicate session
	mut create_err := ''
	s2.create() or  { create_err = err.msg() }
	assert create_err != ''
	assert create_err.contains('duplicate session: testsession2')
	tmux_ls = node_ssh.exec('tmux ls') or { panic("can't exec: $err") }
	assert tmux_ls.contains("testsession2: 1 windows")

	s.stop() or  { panic("Cannot stop session: $err")}
	s2.stop() or  { panic("Cannot stop session: $err")}
}

// fn test_session_stop() {

// 	mut builder := builder.new()
// 	mut node_ssh := builder.node_new(name: 'test', ipaddr: '185.69.166.152', debug: true)!
// 	installer := tmux.get_install(mut node_ssh) or { panic("could not install tmux to node: $err") }

// 	mut tmux := Tmux {
// 		node: node_ssh
// 	}

// 	mut s := Session{
// 		tmux: &tmux // reference back
// 		windows: map[string]&Window{}
// 		name: 'testsession3'
// 	}

// 	s.create() or  { panic("Cannot create session: $err") }
// 	mut tmux_ls := node_ssh.exec('tmux ls') or { panic("can't exec: $err") }
// 	assert tmux_ls.contains("testsession3: 1 windows")
// 	s.stop() or  { panic("Cannot stop session: $err")}
// 	tmux_ls = node_ssh.exec('tmux ls') or { panic("can't exec: $err") }
// 	assert !tmux_ls.contains("testsession3: 1 windows")
// }
