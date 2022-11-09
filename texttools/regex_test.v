module texttools

import os

fn test_stdtext() {
	// this is test without much fancyness, just rext replace, no regex, all case sensitive

	text := '

	this is test_1 SomeTest
	this is test 1 SomeTest

	need to replace TF to ThreeFold
	need to replace ThreeFold0 to ThreeFold
	need to replace ThreeFold1 to ThreeFold

	'

	text_out := '

	this is TTT SomeTest
	this is TTT SomeTest

	need to replace ThreeFold to ThreeFold
	need to replace ThreeFold to ThreeFold
	need to replace ThreeFold to ThreeFold

	'

	mut ri := regex_instructions_new()
	ri.add(['TF:ThreeFold0:ThreeFold1:ThreeFold']) or { panic(err) }
	ri.add_item('test_1', 'TTT') or { panic(err) }
	ri.add_item('test 1', 'TTT') or { panic(err) }

	mut text_out2 := ri.replace(text: text, dedent: true) or { panic(err) }

	// println('!' + dedent(text) + '!')
	// println('!' + dedent(text_out) + '!')
	// println('!' + dedent(text_out2) + '!')

	assert dedent(text_out2).trim('\n') == dedent(text_out).trim('\n')
	// panic('s')
}

fn test_dirreplace() {
	// this is test without much fancyness, just rext replace, no regex, all case sensitive

	// get path where to look for text
	mut p := @FILE.split('/')
	p = p[0..p.len - 1]
	mut path := os.real_path(os.join_path(p.join('/'), 'testdata'))

	mut ri := regex_instructions_new()

	ri.add(['key_bob:KEY_BOB', 'key_alice:KEY_ALICE']) or { panic(err) }

	count := ri.replace_in_dir(path: path, extensions: ['v'], dryrun: true) or { panic(err) }

	assert count == 2
}

// fn test_regex1() {
// 	text := '

// 	this is test_1 SomeTest
// 	this is test 1 SomeTest

// 	need to replace TF to ThreeFold
// 	need to replace ThreeFold0 to ThreeFold
// 	need to replace ThreeFold1 to ThreeFold

// 	'

// 	text_out := '

// 	this is TTT SomeTest
// 	this is TTT SomeTest

// 	need to replace ThreeFold to ThreeFold
// 	need to replace ThreeFold to ThreeFold
// 	need to replace ThreeFold to ThreeFold

// 	'

// 	mut ri := regex_instructions_new(['tf:threefold0:^R ThreeFold1:ThreeFold']) or {
// 		panic(err)
// 	}
// 	ri.add('^Rtest[ _]1', 'TTT') or { panic(err) }
// 	mut text_out2 := ri.replace(text) or { panic(err) }

// 	// println('!' + dedent(text) + '!')
// 	// println('!' + dedent(text_out) + '!')
// 	// println('!' + dedent(text_out2) + '!')

// 	assert dedent(text_out2).trim('\n') == dedent(text_out).trim('\n')
// 	// panic('s')
// }

// fn test_regex2() {
// 	text := '

// 	this is test_1 SomeTest
// 	this is test 1 SomeTest

// 	need to replace ThreeFold 0 to ThreeFold
// 	need to replace ThreeFold0 to ThreeFold
// 	no need to replace ThreeFold1; to ThreeFold

// 	'

// 	text_out := '

// 	'

// 	mut ri := regex_instructions_new(['^Sthreefold 0:bluelagoon']) or {
// 		panic(err)
// 	}

// 	println(ri.get_regex_queries())

// 	// println(ri)

// 	mut text_out2 := ri.replace(text) or { panic(err) }

// 	// println('!' + dedent(text) + '!')
// 	// println('!' + dedent(text_out) + '!')
// 	println('!' + dedent(text_out2) + '!')

// 	assert dedent(text_out2).trim('\n') == dedent(text_out).trim('\n')
// 	// panic('s')
// }
