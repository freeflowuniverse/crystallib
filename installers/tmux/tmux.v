module tmux

// install tmux will return true if it was already installed
pub fn  install() ! {

	println(' - install tmux')
	if osal.cmd_exists('tmux') {
		println('tmux was already installed.')
	}

	return error("implement how to install tmux")

}
