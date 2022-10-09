import freeflowuniverse.crystallib.pathlib { Path }
import os

const testpath = os.dir(@FILE) + '/examples/test_path'

fn testsuite_begin() {
	os.rmdir_all(testpath) or {}
	assert !os.is_dir(testpath)
	os.mkdir_all(testpath)?
	os.mkdir_all('$testpath/test_parent') or {}
	os.create('$testpath/testfile1') or {}
	os.create('$testpath/test_parent/testfile2') or {}
	os.create('$testpath/test_parent/testfile3') or {}
}

fn testsuite_end() {
	os.rmdir_all(testpath) or {}
}

fn test_get() {
	println('************ TEST_Get ************')
	println(testpath)
	fp := pathlib.get('$testpath/testfile1')
	assert fp.cat == pathlib.Category.file
	println('File Result: $fp')
	dp := pathlib.get('$testpath')
	assert dp.cat == pathlib.Category.dir
	println('Dir Result: $dp')
}

fn test_exists() {
	println('************ TEST_exists ************')
	mut p1 := pathlib.get_file('$testpath/testfile1', false) or { panic('$err') }
	assert p1.exists()
	println('File found')
	mut p2 := pathlib.get_file('$testpath/NotARealFile', false) or { panic('$err') }
	assert !p2.exists()
	println('File not found')
	mut p3 := pathlib.get_file('$testpath/NotARealFile2', true) or { panic('$err') }
	assert p3.exists()
	println('File found')
	p3.delete() or { panic('$err') }
	assert !p3.exists()
}

fn test_parent() {
	println('************ TEST_test_parent ************')
	mut test_path_dir := pathlib.get('$testpath')
	mut p := pathlib.get('$testpath/testfile1')
	parent_dir := p.parent() or { panic(err) }
	assert parent_dir == test_path_dir
	println('Parent Function working correctly')
}

fn test_parent_find() {
	println('************ TEST_test_parent_find ************')
	// - testfile1 is located in test_path
	// - will start search from test_parent that is inside test_path
	// - Result must be test_path
	mut test_path_dir := pathlib.get('$testpath')
	mut p := pathlib.get('$testpath/test_parent')
	parent_dir := p.parent_find('testfile1') or { panic(err) }
	assert parent_dir.path == test_path_dir.path
	println('Find Parent Function working correctly')
}

fn test_dir_exists() {
	println('************ TEST_dir_exists ************')
	mut test_path_dir := pathlib.get('$testpath')
	assert test_path_dir.dir_exists('test_parent')
	println('test_parent found in $test_path_dir.path')
	assert !test_path_dir.dir_exists('test_parent_2')
	println('test_paren_2 not found in $test_path_dir.path')
}

fn test_dir_find() {
	println('************ TEST_dir_find ************')
	mut test_path_dir := pathlib.get('$testpath')
	mut test_parent_dir := test_path_dir.dir_get('test_parent') or { panic(err) }
	println('Dir found: $test_parent_dir')
	mut test_parent_dir2 := test_path_dir.dir_get('test_parent_2') or { return }
	panic('should not get here')
}

fn testfile1_exists() {
	println('************ testfile1_exists ************')
	mut test_path_dir := pathlib.get('$testpath')
	assert test_path_dir.file_exists('testfile1')
	println('testfile1 found in $test_path_dir.path')

	assert !test_path_dir.file_exists('newfile2')
	println('newfile2 not found in $test_path_dir.path')
}

fn testfile1_find() {
	println('************ testfile1_find ************')
	mut test_path_dir := pathlib.get('$testpath')
	mut file := test_path_dir.file_find('testfile1') or { panic(err) }
	println('file $file found')
	test_path_dir.file_find('newfile2') or { return }
	panic('should not get here')
}

fn test_real_path() {
	println('************ TEST_real_path ************')
	mut source := pathlib.get('$testpath/test_parent/testfile2')
	mut dest_ := '$testpath/link_remove_rp.md'
	mut link := source.link(dest_, true) or { panic('error: $err') }
	mut dest := pathlib.get(dest_)

	link_real := dest.realpath()
	assert link_real == '$testpath/test_parent/testfile2'
	dest.delete()?
	println('Real path function working correctly')
}

fn test_real_path2() {
	println('************ TEST_real_path ************')
	mut source := pathlib.get('$testpath/testfile1')
	mut dest_ := '$testpath/test_parent/link_remove_rp2.md'
	mut link := source.link(dest_, true) or { panic('error: $err') }
	mut dest := pathlib.get(dest_)
	link_real := dest.realpath()
	assert link_real == '$testpath/testfile1'
	dest.delete()?
	println('Real path2 function working correctly')
}


fn test_link_path_relative() {
	println('************ TEST_link_path_relative ************')
	a1 := pathlib.path_relative('/a/b/c/d.txt', '/a/d.txt')
	assert a1 == '../../d.txt'
	a2 := pathlib.path_relative('/a/b/c/d.txt', '/d.txt')
	assert a2 == '../../../d.txt'
	a3 := pathlib.path_relative('/a/b/c/d.txt', '/a/b/c/e.txt')
	assert a3 == './e.txt' // ? is this the correct path?
	a4 := pathlib.path_relative('/a/b/c/d.txt', '/a/b/d/e.txt')
	assert a4 == '../d/e.txt'
	a5 := pathlib.path_relative('/a/b/c/d.txt', '/a/b/c/d/e/e.txt')
	assert a5 == 'd/e/e.txt'
	a6 := pathlib.path_relative('/a/b/c/', '/a/b/c/e.txt')
	assert a6 == 'e.txt'
	a7 := pathlib.path_relative('/a/b/c', '/a/b/c/e.txt')
	assert a7 == 'e.txt'
	a8 := pathlib.path_relative('/a/b/c', '/a/b/c/d/e/e.txt')
	assert a8 == 'd/e/e.txt'

	println('Link path relative function working correctly')
}

fn test_link() {
	println('************ TEST_link ************')
	mut source1 := pathlib.get('$testpath/test_parent/testfile2')
	mut source2 := pathlib.get('$testpath/test_parent/testfile3')
	assert source1.exists()
	assert source2.exists()

	// test delete exists with nonexistent dest
	mut dest := pathlib.get('$testpath/test_link')
	assert !dest.exists()
	mut link1 := source1.link(dest.path, true) or { panic('no link: $err') }
	assert link1.path == '$testpath/test_link'
	dest = pathlib.get('$testpath/test_link')
	assert dest.exists()

	// test delete exists with existing dest
	assert dest.realpath() == source1.path
	mut link2 := source2.link(dest.path, true) or { panic('no link $err') }
	assert link2.path == '$testpath/test_link'
	assert link2.realpath() != source1.path
	assert link2.realpath() == source2.path

	// test delete_exists false with existing dest
	dest = pathlib.get('$testpath/test_link')
	assert dest.realpath() == source2.path
	mut link3 := source1.link(dest.path, false) or { Path{} }
	assert link3.path == '' // link should error so check empty path obj
	dest = pathlib.get('$testpath/test_link')
	assert dest.realpath() == source2.path // dest reamins unchanged

	dest.delete()?
	println('Link function working correctly')
}

fn test_readlink() {
	println('************ TEST_readlink ************')
	// test with none link path
	mut source := pathlib.get('$testpath/test_parent/testfile2')
	mut dest_ := '$testpath/test_readlink.md'
	path := source.readlink() or { Path{} }
	assert path == Path{}

	// test with filelink path
	mut link := source.link(dest_, true) or { panic('error: $err') }
	mut dest := pathlib.get(dest_)

	assert dest.cat == .linkfile
	assert dest.path == dest_

	link_source := dest.readlink() or { Path{} }
	assert link_source.path == 'test_parent/testfile2'

	dest.delete()?
	println('Readlink function working correctly')
}

fn test_unlink() {
	println('************ TEST_unlink ************')
	// test with filelink path

	mut source := pathlib.get('$testpath/test_parent/testfile2')
	mut dest_ := '$testpath/test_unlink.md'

	mut link := source.link(dest_, true) or { panic('error: $err') }
	mut dest := pathlib.get(dest_)

	// TODO: check if content is from source

	assert dest.cat == .linkfile
	dest.unlink() or { panic('Failed to unlink: $err') }
	assert dest.exists()
	assert dest.cat == .file

	dest.delete()?

	// TODO: maybe more edge cases?
	println('Unlink function working correctly')
}

fn test_relink() {
	println('************ TEST_relink ************')

	mut source := pathlib.get('$testpath/test_parent/testfile2')
	mut dest_ := '$testpath/test_relink.md'
	mut link := source.link(dest_, true) or { panic('error: $err') }
	mut dest := pathlib.get(dest_)

	// linked correctly so doesn't change
	assert source.cat == .file
	assert dest.cat == .linkfile
	dest.relink() or { panic('Failed to relink: $err') }
	source_new := pathlib.get(source.path)
	assert source_new.cat == .file
	assert dest.cat == .linkfile

	// switching source and destination
	mut source2 := pathlib.get(dest_)
	source2.unlink() or { panic('Failed to unlink: $err') }
	mut dest2_ := source.path

	// linked incorrectly so should relink
	mut link2 := source2.link(dest2_, true) or { panic('error: $err') }
	mut dest2 := pathlib.get(dest2_)
	assert source2.cat == .file
	assert dest2.cat == .linkfile
	dest2.relink() or { panic('Failed to relink: $err') }
	source2_new := pathlib.get(source2.path)
	assert source2_new.cat == .linkfile
	assert dest2.cat == .file

	dest.delete()?
}

fn test_list() {
	println('************ TEST_list ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.list(recursive: true) or { panic(err) }
	println(result)
}

fn test_list_dirs() {
	println('************ TEST_list_dir ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.dir_list(recursive: true) or { panic(err) }
	println(result)
}

fn test_list_files() {
	println('************ TEST_list_files ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.file_list(recursive: true) or { panic(err) }
	println(result)
}

fn test_list_links() {
	println('************ TEST_list_link ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.link_list(pathlib.ListArgs{}) or { panic(err) }
	println(result)
}

fn test_write_and_read() {
	println('************ TEST_write_and_read ************')
	mut fp := pathlib.get('$testpath/testfile1')
	fp.write('Test Write Function') or { panic(err) }
	fcontent := fp.read() or { panic(err) }
	assert fcontent == 'Test Write Function'
	println('Write and read working correctly')

	// mut test_path_dir := pathlib.get("$testpath")
}

fn test_copy() {
	println('************ TEST_copy ************')
	//- Copy /test_path/testfile1 to /test_path/test_parent
	mut dest_dir := pathlib.get('$testpath/test_parent')
	mut src_f := pathlib.get('$testpath/testfile1')
	mut dest_file := src_f.copy(mut dest_dir) or { panic(err) }
	assert dest_file.path == '$testpath/test_parent/testfile1'
	dest_file.delete()?
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

	b5 := pathlib.find_common_ancestor(['', '/a/b/c/d.txt'])
	assert b5 == '/'

	b6 := pathlib.find_common_ancestor(['/a/b/c/d.txt', ''])
	assert b6 == '/'

	b7 := pathlib.find_common_ancestor(['/', '/a/b/c/d.txt'])
	assert b7 == '/'
	println('Find common ancestor function works correctly')
}
