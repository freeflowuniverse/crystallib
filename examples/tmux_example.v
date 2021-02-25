import os
import tmux
import builder

fn tmuxtest(node_args builder.NodeArguments) ?bool {
	os.log('TMUX-EXAMPLE - Create tmux object, scan function called')
	mut t := tmux.new(node_args)

	os.log("TMUX-EXAMPLE - Get/Create 'test_session'")
	mut test_session := t.session_get('test_session', false)
	assert test_session.name == 'test_session'

	os.log("TMUX-EXAMPLE - Get/Create 'test_window'")
	mut test_window := test_session.window_get('test_window')
	assert test_window.name == 'test_window'

	cmd := 'mkdir ~/TestTmux'
	cmd_check := 'cd ~/TestTmux'
	os.log('TMUX-EXAMPLE - Execute $cmd')
	test_window.execute(cmd, '', false)
	test_window.execute(cmd_check, '', false)

	os.log('TMUX-EXAMPLE - Stop all sessions')
	t.stop()

	return true
}

fn local() {
	// Empty NodeArguments struct refrer to localhost node
	local_node := builder.NodeArguments{}
	tmuxtest(local_node) or { panic('err: $err | errcode: $errcode') }
}

fn remote() {
	remote_node := builder.NodeArguments{
		ipaddr: '174.138.48.10:22:22'
		name: 'myremoteserver'
		user: 'root'
	}
	tmuxtest(remote_node) or { panic('err: $err | errcode: $errcode') }
}

fn main() {
	local()
	// remote()
}
