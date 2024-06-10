module playcmds

import freeflowuniverse.crystallib.core.playbook

const dagu_script = "
	!!dagu.configure
	instance: 'test'

	!!dagu.new_dag
	name: 'run test'

	!!dagu.add_step
	dag: 'deploy_playground'
	name: 'install_baobab'
	command: 'echo hello world'

	!!dagu.add_step
	dag: 'deploy_playground'
	name: 'run_playground'
	command: 'baobab playground'
"

fn test_play_dagu() ! {
	mut plbook := playbook.new(text: playcmds.dagu_script)!
	play_dagu(mut plbook)!
}
