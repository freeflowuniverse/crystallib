module codeparser

import freeflowuniverse.crystallib.codemodel {CodeItem, Function, Struct}

import os

const testpath = os.dir(@FILE) + '/testdata'

// tests parsing blank directory, should return empty codeitem array.
fn test_vparse_blankdir() ! {
	$if debug {
		eprintln('\nTEST: test_vparse_blankdir\n')
	}
	code := parse_v('$testpath/blankdir')!
	assert code.len == 0
}

// tests whether can parse a flat directory
// with no subdirectories but multiple files
fn test_vparse_flatdir() ! {
	$if debug {
		eprintln('\nTEST: test_vparse_flatdir\n')
	}
	code := parse_v('$testpath/flatdir')!
	assert code.len == 12

	assert code[0] is Function
	function0 := code[0] as Function
	assert function0.name == 'anotherfile_func0'

	assert code[1] is Function
	function1 := code[1] as Function
	assert function1.name == 'anotherfile_func1'
}

// tests wheter can parse a directory with subdirectories
// without recursing into subdirectories
fn test_vparse_non_recursive() ! {
	$if debug {
		eprintln('\nTEST: test_vparse_non_recursive\n')
	}
	code := parse_v(testpath)!
	// should be only 6 since 
	assert code.len == 6

	assert code[0] is Function
	function0 := code[0] as Function
	assert function0.name == 'file_func0'

	assert code[1] is Function
	function1 := code[1] as Function
	assert function1.name == 'file_func1'
}

// tests wheter can parse a directory with subdirectories
// with recursing into subdirectories
fn test_vparse_recursive() ! {
	$if debug {
		eprintln('\nTEST: test_vparse_recursive\n')
	}
	code := parse_v(testpath, recursive: true)!
	// should be 18 since there are 3 files with 6 CodeItems each
	assert code.len == 18

	assert code[0] is Function
	function0 := code[0] as Function
	assert function0.name == 'anotherfile_func0'

	assert code[1] is Function
	function1 := code[1] as Function
	assert function1.name == 'anotherfile_func1'
}

// tests wheter can parse a directory with subdirectories
// and exclude a directory
fn test_vparse_exclude_dirs() ! {
	$if debug {
		eprintln('\nTEST: test_vparse_recursive\n')
	}
	code := parse_v(testpath, 
	recursive: true
	exclude_dirs: ['flatdir']
	)!

	// should be 6 since there is only 1 file with 6 CodeItems excluding flatdir
	assert code.len == 6

	// codeitems should have prefix file_func since anotherfile and subfile are excluded
	assert code[0] is Function
	function0 := code[0] as Function
	assert function0.name == 'file_func0'

	assert code[1] is Function
	function1 := code[1] as Function
	assert function1.name == 'file_func1'
}

// tests wheter can parse a directory with subdirectories
// and exclude a file
fn test_vparse_exclude_files() ! {
	$if debug {
		eprintln('\nTEST: test_vparse_recursive\n')
	}
	code := parse_v(testpath, 
	recursive: true
	exclude_files: ['flatdir/anotherfile.v']
	)!

	// should be 12 since there are 2 files with 6 CodeItems excluding anotherfile.v
	assert code.len == 12

	// codeitems should have prefix file_func since anotherfile and subfile are excluded
	assert code[0] is Function
	function0 := code[0] as Function
	assert function0.name == 'subfile_func0'

	assert code[1] is Function
	function1 := code[1] as Function
	assert function1.name == 'subfile_func1'
}

// tests wheter can parse a directory with subdirectories
// and exclude a file
fn test_vparse_only_pub() ! {
	$if debug {
		eprintln('\nTEST: test_vparse_recursive\n')
	}
	code := parse_v(testpath, 
		recursive: true
		only_pub: true
	)!

	// should be 12 since there are 2 files with 6 CodeItems excluding anotherfile.v
	assert code.len == 15

	// codeitems should have prefix file_func since anotherfile and subfile are excluded
	assert code[0] is Function
	function0 := code[0] as Function
	assert function0.name == 'anotherfile_func1'

	assert code[1] is Struct
	function1 := code[1] as Struct
	assert function1.name == 'AnotherfileStruct0'
}