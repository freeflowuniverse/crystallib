module gittools

import json

fn test_url1() {
	gs := new("",false) or {panic("init. $err")}

	url := 'https://github.com/vlang/v/blob/master/doc/docs.md#maps'
	obj := gs.addr_get_from_url(url) or {panic("$err")}

	tocompare := GitAddr{
		root: '/Users/despiegk/code/'
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
	gs := new("",false) or {panic("init. $err")}

	url := 'git@github.com:crystaluniverse/publishtools/tree/development/doc'
	obj := gs.addr_get_from_url(url) or {panic("$err")}

	println(obj)

	tocompare := GitAddr{
		root: '/Users/despiegk/code/'
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
// 	gs := new("",false)?

// 	url := 'https://github.com/vlang/v/blob/master/doc/docs.md'
// 	obj := gs.addr_get_from_url(url)

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
// 	gs := new("",false)?

// 	url := 'https://github.com/vlang/v/blob/master/'
// 	obj := gs.addr_get_from_url(url)

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
// 	gs := new("",false)?

// 	url := 'https://github.com/vlang/v'
// 	obj := gs.addr_get_from_url(url)

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
// 	gs := new("",false)?

// 	url := 'https://github.com/vlang/v.git'
// 	obj := gs.addr_get_from_url(url)

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
// 	gs := new("",false)?

// 	url := 'http://github.com/vlang/v.git'
// 	obj := gs.addr_get_from_url(url)

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
// 	gs := new("",false)?

// 	url := 'git@github.com:vlang/v.git'
// 	obj := gs.addr_get_from_url(url)

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
// 	gs := new("",false)?

// 	url := 'github.com:vlang/v.git'
// 	obj := gs.addr_get_from_url(url)

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
// 	gs := new("",false)?

// 	url := 'github.com:vlang/v'
// 	obj := gs.addr_get_from_url(url)

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
// 	mut s := new("",false)?

// 	addr := s.addr_get_from_url('https://github.com/crystaluniverse/crystaltools')
// 	mut r := s.repo_get(addr) or { panic('cannot load git $addr.url\n$err\n') }

// 	println(r.url_get())

// 	if ssh_agent_loaded() {
// 		assert r.url_get() == 'git@github.com:crystaluniverse/crystaltools.git'
// 	} else {
// 		assert r.url_get() == 'https://github.com/crystaluniverse/crystaltools'
// 	}

// 	path := '~/code/github/crystaluniverse/crystaltools'
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
// 	mut s := new("",false)?

// 	addr := s.addr_get_from_url('https://github.com/crystaluniverse/crystaltools')
// 	mut r := s.repo_get(addr) or { panic('cannot load git repo:\n$err\n$addr') }

// 	println(r.changes())

// 	panic('s')
// }
