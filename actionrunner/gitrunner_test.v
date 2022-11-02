module actionrunner

import os
import freeflowuniverse.crystallib.params { Param, Params }

fn test_run_pull() {
	mut gitrunner := new_gitrunner()
	go gitrunner.run()
	msg := ActionMessage{
		name: 'git.pull'
		params: Params{
			params: [
				Param{
					key: 'url'
					value: 'https://github.com/threefoldfoundation/books/tree/main/books'
				},
				Param{
					key: 'name'
					value: 'books'
				},
			]
			args: []
		}
	}
	gitrunner.channel <- msg
	for {
		res := <-gitrunner.channel
		if res.name == msg.name && res.params == msg.params {
			assert res.complete
			break
		}
	}
	pull_cmd := 'cd $os.home_dir()/code/github/threefoldfoundation/books && git pull'
	output := os.execute(pull_cmd).output.trim_string_right('\n')
	assert output == 'Already up to date.'
}

fn test_run_link() {
	mut gitrunner := new_gitrunner()
	go gitrunner.run()
	msg := ActionMessage{
		name: 'git.link'
		params: Params{
			params: [
				Param{
					key: 'gitsource'
					value: 'owb'
				},
				Param{
					key: 'gitdest'
					value: 'books'
				},
				Param{
					key: 'source'
					value: 'feasibility_study/Capabilities'
				},
				Param{
					key: 'dest'
					value: 'feasibility_study_internet/src/capabilities2'
				},
			]
			args: []
		}
	}
	gitrunner.channel <- msg
	for {
		res := <-gitrunner.channel
		if res.name == msg.name && res.params == msg.params {
			assert res.complete
			break
		}
	}
}

fn test_run_multibranch() {
	mut gitrunner := new_gitrunner()
	go gitrunner.run()
	msg := ActionMessage{
		name: 'git.params.multibranch'
		params: Params{
			params: [
				Param{
					key: 'name'
					value: 'books'
				},
			]
			args: []
		}
	}
	gitrunner.channel <- msg
	for {
		res := <-gitrunner.channel
		if res.name == msg.name && res.params == msg.params {
			assert res.complete
			break
		}
	}
}

fn test_run() {
	mut gitrunner := new_gitrunner()
	go gitrunner.run()
}
