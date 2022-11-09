module gittools

import json
import os

fn test_url1() {
	mut gs := get(GSConfig{}) or { panic('cannot load') }

	url := 'https://github.com/vlang/v/blob/master/doc/docs.md#maps'
	obj := addr_get_from_url(url) or { panic('$err') }

	// home := os.real_path(os.home_dir())

	tocompare := GitAddr{
		// root: '$home/code/'
		provider: 'github.com'
		account: 'vlang'
		name: 'v'
		path: 'doc/docs.md'
		branch: 'master'
		anker: 'maps'
		depth: 0
	}

	assert json.encode(obj) == json.encode(tocompare)
}

fn test_url2() {
	mut gs := get(GSConfig{}) or { panic('cannot load') }

	url := 'git@github.com:crystaluniverse/publishtools/tree/development/doc'
	obj := addr_get_from_url(url) or { panic('$err') }

	println(obj)

	// home := os.real_path(os.home_dir())

	tocompare := GitAddr{
		// root: '$home/code/'
		provider: 'github.com'
		account: 'crystaluniverse'
		name: 'publishtools'
		path: 'doc'
		branch: 'development'
		anker: ''
		depth: 0
	}

	assert json.encode(obj) == json.encode(tocompare)
}

// fn test_url2() {
// 	gs := new("",false)!

// 	url := 'https://github.com/vlang/v/blob/master/doc/docs.md'
// 	obj := addr_get_from_url(url)

// 	tocompare := GitAddr{
// 		provider: 'github.com'
// 		account: 'vlang'
// 		repo: 'v'
// 		path: 'doc/docs.md'
// 		branch: 'master'
// 	}

// 	assert json.encode(obj) == json.encode(tocompare)
// }

// fn test_url3() {
// 	gs := new("",false)!

// 	url := 'https://github.com/vlang/v/blob/master/'
// 	obj := addr_get_from_url(url)

// 	tocompare := GitAddr{
// 		provider: 'github.com'
// 		account: 'vlang'
// 		repo: 'v'
// 		path: ''
// 		branch: 'master'
// 	}

// 	assert json.encode(obj) == json.encode(tocompare)
// }

// fn test_url4() {
// 	gs := new("",false)!

// 	url := 'https://github.com/vlang/v'
// 	obj := addr_get_from_url(url)

// 	tocompare := GitAddr{
// 		provider: 'github.com'
// 		account: 'vlang'
// 		repo: 'v'
// 		path: ''
// 		branch: ''
// 	}

// 	assert json.encode(obj) == json.encode(tocompare)
// }

// fn test_url4b() {
// 	gs := new("",false)!

// 	url := 'https://github.com/vlang/v.git'
// 	obj := addr_get_from_url(url)

// 	tocompare := GitAddr{
// 		provider: 'github.com'
// 		account: 'vlang'
// 		repo: 'v'
// 		path: ''
// 		branch: ''
// 	}

// 	assert json.encode(obj) == json.encode(tocompare)
// }

// fn test_url4c() {
// 	gs := new("",false)!

// 	url := 'http://github.com/vlang/v.git'
// 	obj := addr_get_from_url(url)

// 	tocompare := GitAddr{
// 		provider: 'github.com'
// 		account: 'vlang'
// 		repo: 'v'
// 		path: ''
// 		branch: ''
// 	}

// 	assert json.encode(obj) == json.encode(tocompare)
// }

// fn test_url5() {
// 	gs := new("",false)!

// 	url := 'git@github.com:vlang/v.git'
// 	obj := addr_get_from_url(url)

// 	tocompare := GitAddr{
// 		provider: 'github.com'
// 		account: 'vlang'
// 		repo: 'v'
// 		path: ''
// 		branch: ''
// 	}

// 	assert json.encode(obj) == json.encode(tocompare)
// }

// fn test_url6() {
// 	gs := new("",false)!

// 	url := 'github.com:vlang/v.git'
// 	obj := addr_get_from_url(url)

// 	tocompare := GitAddr{
// 		provider: 'github.com'
// 		account: 'vlang'
// 		repo: 'v'
// 		path: ''
// 		branch: ''
// 	}

// 	assert json.encode(obj) == json.encode(tocompare)
// }

// fn test_url7() {
// 	gs := new("",false)!

// 	url := 'github.com:vlang/v'
// 	obj := addr_get_from_url(url)

// 	tocompare := GitAddr{
// 		provider: 'github.com'
// 		account: 'vlang'
// 		repo: 'v'
// 		path: ''
// 		branch: ''
// 	}

// 	assert json.encode(obj) == json.encode(tocompare)
// }

// fn test_path1() {
// 	mut s := new("",false)!

// 	addr := s.addr_get_from_url('https://github.com/freeflowuniverse/crystaltools')
// 	mut r := s.repo_get(addr) or { panic('cannot load git $addr.url\n$err\n') }

// 	println(r.url_get())

// 	if ssh_agent_loaded() {
// 		assert r.url_get() == 'git@github.com:freeflowuniverse/crystaltools.git'
// 	} else {
// 		assert r.url_get() == 'https://github.com/freeflowuniverse/crystaltools'
// 	}

// 	path := '~/code/github/freeflowuniverse/crystaltools'
// 	obj := addr_get_from_path(path)

// 	tocompare := GitAddr{
// 		provider: 'github.com'
// 		account: 'crystaluniverse'
// 		repo: 'crystaltools'
// 		path: ''
// 		branch: ''
// 	}

// 	assert json.encode(obj) == json.encode(tocompare)
// }

// fn test_changes() {
// 	mut s := new("",false)!

// 	addr := s.addr_get_from_url('https://github.com/freeflowuniverse/crystaltools')
// 	mut r := s.repo_get(addr) or { panic('cannot load git repo:\n$err\n$addr') }

// 	println(r.changes())

// 	panic('s')
// }
