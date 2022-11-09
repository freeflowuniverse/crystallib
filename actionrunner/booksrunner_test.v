module actionrunner

import os
import freeflowuniverse.crystallib.params { Param, Params }
import freeflowuniverse.crystallib.pathlib

//test adding book with url as a path
fn test_run_add() {
	mut booksrunner := new_booksrunner()
	go booksrunner.run()
	msg := ActionMessage{
		name: 'books.add'
		params: Params{
			params: [
				Param{
					key: 'path'
					value: 'https://github.com/threefoldfoundation/books/tree/main/books/cyberpandemic/src'
				},
				Param{
					key: 'name'
					value: 'cyberpandemic'
				},
			]
			args: []
		}
	}
	booksrunner.channel <- msg
	for {
		res := <-booksrunner.channel
		if res.name == msg.name && res.params == msg.params {
			assert res.complete
			break
		}
	}
	// pull_cmd := 'cd $os.home_dir()/code/github/threefoldfoundation/books && git pull'
	// output := os.execute(pull_cmd).output.trim_string_right('\n')
	// assert output == 'Already up to date.'
}

// test adding book with gitsource and relative path in repo
fn test_run_add1() {
	mut booksrunner := new_booksrunner()
	go booksrunner.run()
	msg := ActionMessage{
		name: 'books.add'
		params: Params{
			params: [
				Param{
					key: 'gitsource'
					value: 'books'
				},
				Param{
					key: 'path'
					value: 'cyberpandemic/src'
				},
				Param{
					key: 'name'
					value: 'cyberpandemic'
				},
			]
			args: []
		}
	}
	booksrunner.channel <- msg
	for {
		res := <-booksrunner.channel
		if res.name == msg.name && res.params == msg.params {
			assert res.complete
			break
		}
	}
	// pull_cmd := 'cd $os.home_dir()/code/github/threefoldfoundation/books && git pull'
	// output := os.execute(pull_cmd).output.trim_string_right('\n')
	// assert output == 'Already up to date.'
}

fn test_run_develop() {
	mut booksrunner := new_booksrunner()
	go booksrunner.run()

	// manually adding book for test
	mut gr := booksrunner.gt.repo_get_from_url(
		url: 'https://github.com/threefoldfoundation/books/tree/main/books/technology/src'
		pull: false
		reset: false
		name: 'technology'
	) or { panic('Could not get repository from url') }
	book_path := gr.path_content_get()
	booksrunner.books.book_new(path: book_path, name: 'technology') or { panic("Can't get new site: $err") }

	// sending runner message to develop book
	msg := ActionMessage{
		name: 'books.mdbook_develop'
		params: Params{
			params: [
				Param{
					key: 'name'
					value: 'technology'
				}
			]
			args: []
		}
	}
	booksrunner.channel <- msg
	
	// testing is complete response from channel
	for {
		res := <-booksrunner.channel
		if res.name == msg.name && res.params == msg.params {
			assert res.complete
			break
		}
	}
	// pull_cmd := 'cd $os.home_dir()/code/github/threefoldfoundation/books && git pull'
	// output := os.execute(pull_cmd).output.trim_string_right('\n')
	// assert output == 'Already up to date.'
}

// fn test_run_link() {
// 	mut booksrunner := new_booksrunner()
// 	go booksrunner.run()
// 	msg := ActionMessage{
// 		name: 'git.link'
// 		params: Params{
// 			params: [
// 				Param{
// 					key: 'gitsource'
// 					value: 'owb'
// 				},
// 				Param{
// 					key: 'gitdest'
// 					value: 'books'
// 				},
// 				Param{
// 					key: 'source'
// 					value: 'feasibility_study/Capabilities'
// 				},
// 				Param{
// 					key: 'dest'
// 					value: 'feasibility_study_internet/src/capabilities2'
// 				},
// 			]
// 			args: []
// 		}
// 	}
// 	booksrunner.channel <- msg
// 	for {
// 		res := <-booksrunner.channel
// 		if res.name == msg.name && res.params == msg.params {
// 			assert res.complete
// 			break
// 		}
// 	}
// }

// fn test_run_multibranch() {
// 	mut booksrunner := new_booksrunner()
// 	go booksrunner.run()
// 	msg := ActionMessage{
// 		name: 'git.params.multibranch'
// 		params: Params{
// 			params: [
// 				Param{
// 					key: 'name'
// 					value: 'books'
// 				},
// 			]
// 			args: []
// 		}
// 	}
// 	booksrunner.channel <- msg
// 	for {
// 		res := <-booksrunner.channel
// 		if res.name == msg.name && res.params == msg.params {
// 			assert res.complete
// 			break
// 		}
// 	}
// }

// fn test_run() {
// 	mut booksrunner := new_booksrunner()
// 	go booksrunner.run()
// }
