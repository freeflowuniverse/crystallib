module main

import os

const (
	cli_path       = '${os.dir(os.dir(os.dir(os.dir(@FILE))))}/crystallib/baobab/hero/executor'
	script_path    = '${os.dir(@FILE)}/do.md'
	script_git_url = 'https://github.com/freeflowuniverse/crystallib/blob/development/examples/knowledgetree/smallbook_3script/do.md'
	code_root      = '${os.home_dir()}/code'
)

pub fn main() {
	do() or { panic(err) }
}

pub fn do() ! {
	result := os.execute('v -w -cg -enable-globals ${cli_path}') // compile hero cli
	if result.exit_code == 1 {
		println('debug: ${result.output}')
	}
	hero_args := ['3script', '-p', script_git_url, '-cr', code_root]
	os.execvp('${cli_path}/executor', hero_args)! // run as child process
}
