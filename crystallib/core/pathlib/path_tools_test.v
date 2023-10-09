import freeflowuniverse.crystallib.core.pathlib
import os

const testpath = os.dir(@FILE) + '/examples/test_path'

fn testsuite_begin() {
	os.rmdir_all(testpath) or {}
	assert !os.is_dir(testpath)
	os.mkdir_all(testpath) or { panic(err) }
	os.mkdir_all('${testpath}/test_parent') or { panic(err) }
	os.mkdir_all('${testpath}/a/b/c') or { panic(err) }
	os.create('${testpath}/testfile1') or { panic(err) }
	os.create('${testpath}/test_parent/testfile2') or { panic(err) }
	os.create('${testpath}/test_parent/testfile3') or { panic(err) }
}

fn testsuite_end() {
	os.rmdir_all(testpath) or {}
}

fn test_get() {
	println('************ TEST_Get ************')
	println(testpath)
	fp := pathlib.get('${testpath}/testfile1')
	assert fp.cat == pathlib.Category.file
	println('File Result: ${fp}')
	dp := pathlib.get('${testpath}')
	assert dp.cat == pathlib.Category.dir
	println('Dir Result: ${dp}')
}

fn test_exists() {
	println('************ TEST_exists ************')
	mut p1 := pathlib.get_file('${testpath}/testfile1', false) or { panic('${err}') }
	assert p1.exists()
	println('File found')
	mut p2 := pathlib.get_file('${testpath}/NotARealFile', false) or { panic('${err}') }
	assert !p2.exists()
	println('File not found')
	mut p3 := pathlib.get_file('${testpath}/NotARealFile2', true) or { panic('${err}') }
	assert p3.exists()
	println('File found')
	p3.delete() or { panic('${err}') }
	assert !p3.exists()
}

fn test_parent() {
	println('************ TEST_test_parent ************')
	mut test_path_dir := pathlib.get('${testpath}')
	mut p := pathlib.get('${testpath}/testfile1')
	parent_dir := p.parent() or { panic(err) }
	assert parent_dir == test_path_dir
	println('Parent Function working correctly')
}

fn test_parent_find() {
	println('************ TEST_test_parent_find ************')
	// - testfile1 is located in test_path
	// - will start search from test_parent that is inside test_path
	// - Result must be test_path
	mut test_path_dir := pathlib.get('${testpath}')
	mut p := pathlib.get('${testpath}/test_parent')
	parent_dir := p.parent_find('testfile1') or { panic(err) }
	assert parent_dir.path == test_path_dir.path
	println('Find Parent Function working correctly')
}

fn test_dir_exists() {
	println('************ TEST_dir_exists ************')
	mut test_path_dir := pathlib.get('${testpath}')
	assert test_path_dir.dir_exists('test_parent')
	println('test_parent found in ${test_path_dir.path}')
	assert !test_path_dir.dir_exists('test_parent_2')
	println('test_paren_2 not found in ${test_path_dir.path}')
}

fn test_dir_find() {
	println('************ TEST_dir_find ************')
	mut test_path_dir := pathlib.get('${testpath}')
	mut test_parent_dir := test_path_dir.dir_get('test_parent') or { panic(err) }
	println('Dir found: ${test_parent_dir}')
	mut test_parent_dir2 := test_path_dir.dir_get('test_parent_2') or { return }
	panic('should not get here')
}

fn testfile1_exists() {
	println('************ testfile1_exists ************')
	mut test_path_dir := pathlib.get('${testpath}')
	assert test_path_dir.file_exists('testfile1')
	println('testfile1 found in ${test_path_dir.path}')

	assert !test_path_dir.file_exists('newfile2')
	println('newfile2 not found in ${test_path_dir.path}')
}

fn testfile1_find() {
	println('************ testfile1_find ************')
	mut test_path_dir := pathlib.get('${testpath}')
	mut file := test_path_dir.file_get('testfile1') or { panic(err) }
	println('file ${file} found')
	test_path_dir.file_get('newfile2') or { return }
	panic('should not get here')
}

fn test_real_path() {
	println('************ TEST_real_path ************')
	mut source := pathlib.get('${testpath}/test_parent/testfile2')
	mut dest_ := '${testpath}/link_remove_rp.md'
	mut link := source.link(dest_, true) or { panic('error: ${err}') }
	mut dest := pathlib.get(dest_)
	link_real := dest.realpath()
	assert link_real == '${testpath}/test_parent/testfile2'
	// dest.delete() or {panic(err)}
	println('Real path function working correctly')
}

fn test_real_path2() {
	println('************ TEST_real_path ************')
	mut source := pathlib.get('${testpath}/testfile1')
	mut dest_ := '${testpath}/test_parent/link_remove_rp2.md'
	mut link := source.link(dest_, true) or { panic('error: ${err}') }
	mut dest := pathlib.get(dest_)
	link_real := dest.realpath()
	assert link_real == '${testpath}/testfile1'
	dest.delete() or { panic(err) }
	println('Real path2 function working correctly')
}

fn test_link_path_relative() {
	os.mkdir_all('${testpath}/a/b/c') or { panic(err) }
	println('************ TEST_link_path_relative()! ************')
	a0 := pathlib.path_relative('${testpath}/a/b/c', '${testpath}/a/d.txt') or { panic(err) }
	assert a0 == '../../d.txt'
	a2 := pathlib.path_relative('${testpath}/a/b/c', '${testpath}/d.txt') or { panic(err) }
	assert a2 == '../../../d.txt'
	a3 := pathlib.path_relative('${testpath}/a/b/c', '${testpath}/a/b/c/e.txt') or { panic(err) }
	assert a3 == 'e.txt' // ? is this the correct path?
	a4 := pathlib.path_relative('${testpath}/a/b/c/', '${testpath}/a/b/d/e.txt') or { panic(err) }
	assert a4 == '../d/e.txt'
	a5 := pathlib.path_relative('${testpath}/a/b/c', '${testpath}/a/b/c/d/e/e.txt') or {
		panic(err)
	}
	assert a5 == 'd/e/e.txt'
	a6 := pathlib.path_relative('${testpath}/a/b/c', '${testpath}/a/b/c/e.txt') or { panic(err) }
	assert a6 == 'e.txt'
	a7 := pathlib.path_relative('${testpath}/a/b/c', '${testpath}/a/b/c/e.txt') or { panic(err) }
	assert a7 == 'e.txt'
	a8 := pathlib.path_relative('${testpath}/a/b/c', '${testpath}/a/b/c/d/e/e.txt') or {
		panic(err)
	}
	assert a8 == 'd/e/e.txt'

	// TODO: lets make to work in test setup
	// c := pathlib.path_relative('/Users/despiegk1/code4/books/content/mytwin/intro','/Users/despiegk1/code4/books/content/mytwin/funny_comparison.md') or {panic(err)}
	// assert c=="../funny_comparison.md"
	// d := pathlib.path_relative('/Users/despiegk1/code4/books/content/mytwin/intro/','/Users/despiegk1/code4/books/content/mytwin/funny_comparison.md') or {panic(err)}
	// assert d=="../funny_comparison.md"

	println('Link path relative function working correctly')
}

// TODO need to enable all tests
// TODO have more than 1 test file, make more modular, now its 1 too big file

fn test_write_and_read() {
	println('************ TEST_write_and_read ************')
	mut fp := pathlib.get('${testpath}/testfile1')
	fp.write('Test Write Function') or { panic(err) }
	fcontent := fp.read() or { panic(err) }
	assert fcontent == 'Test Write Function'
	println('Write and read working correctly')

	// mut test_path_dir := pathlib.get("$testpath")
}

fn test_copy() {
	println('************ TEST_copy ************')
	//- Copy /test_path/testfile1 to /test_path/test_parent
	mut dest_dir := pathlib.get('${testpath}/test_parent')
	mut src_f := pathlib.get('${testpath}/testfile1')
	mut dest_file := src_f.copy(mut dest_dir) or { panic(err) }
	assert dest_file.path == '${testpath}/test_parent/testfile1'
	dest_file.delete()!
	println('Copy function works correctly')
}

// TODO need other test
// fn test_link(){
// 	println('************ TEST_link ************')
// 	mut dest_p:= path.path{path:"$testpath/linkdir1", cat:pathlib.Category.linkdir, exists:path.false}
// 	mut lp := path.path{path:"/workspace/crystallib/path", cat:pathlib.Category.dir, exists:path.true}
// 	lp.link(mut dest_p) or {panic(err)}
// 	mut get_link := pathlib.get("$testpath/linkdir1")
// 	assert get_link.exists()
// 	println("Link path: $get_link.path")
// 	real:= get_link.absolute()
// 	println("Real path: $real")
// }

fn test_find_common_ancestor() {
	println('************ TEST_find_common_ancestor ************')
	res := pathlib.find_common_ancestor(['/test/a/b/c/d', '/test/a/'])
	assert res == '/test/a'

	b1 := pathlib.find_common_ancestor(['/a/b/c/d.txt', '/a/d.txt'])
	assert b1 == '/a'

	b2 := pathlib.find_common_ancestor(['/a/b/c/d.txt', '/c/d.txt'])
	assert b2 == '/'

	b3 := pathlib.find_common_ancestor(['/a/b/c/d.txt', '/a/b/c/e.txt'])
	assert b3 == '/a/b/c'

	b4 := pathlib.find_common_ancestor(['/a/b/c/d.txt', '/a/b/c/d.txt'])
	assert b4 == '/a/b/c/d.txt'

	b7 := pathlib.find_common_ancestor(['/', '/a/b/c/d.txt'])
	assert b7 == '/'
	println('Find common ancestor function works correctly')
}