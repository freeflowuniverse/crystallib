module main

import os
import cli { Command }
import v.util
import v.pref

const (
	external_tools = ['build-examples.v']
)

fn do() ! {
	mut cmd := Command{
		name: 'crystallib'
		description: 'Crystallib CLI'
		version: '1.0.0'
		disable_man: true
	}

	cmd_build_examples(mut cmd)
	cmd.setup()
	cmd.parse(os.args)
}

fn main() {
	do() or { panic(err) }
}

pub fn cmd_build_examples(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'build_examples'
		description: 'Build the examples in crystallib.'
		usage: ''
		required_args: 0
		execute: cmd_build_examples_execute
	}
	cmdroot.add_command(cmd_run)
}

fn cmd_build_examples_execute(cmd Command) ! {
	mut args_and_flags := util.join_env_vflags_and_os_args()[1..]
	// file_dir := os.dir(@FILE)
	// os.execute('v run ${file_dir}/build_examples.v')
	// command := 'v run ${file_dir}/build_examples.v'
	prefs, command := pref.parse_args_and_show_errors(external_tools, args_and_flags,
		true)
	println('cmd: ${command}')
	util.launch_tool(prefs.is_verbose, 'v' + command, [])
}
