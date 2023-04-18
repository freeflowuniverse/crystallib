module codeparser

import freeflowuniverse.crystallib.codemodel {CodeItem, Function, Struct}

import os

const testpath = os.dir(@FILE) + '/testdata'

// is a map of test files used in these tests and their complete codeitems
// used to make assertions and verify test outputs
const testcode = {
	'anotherfile.v': [
		codemodel.CodeItem(codemodel.Function{
			name: 'anotherfile_func0'
			receiver: codemodel.Param{
				description: ''
				name: ''
				typ: codemodel.Type{
					symbol: ''
				}
			}
			description: ''
			params: []
			body: ''
			result: codemodel.Result{
				typ: codemodel.Type{
					symbol: 'void'
				}
				description: ''
				name: ''
			}
			has_return: false
		}), codemodel.CodeItem(codemodel.Function{
			name: 'anotherfile_func1'
			receiver: codemodel.Param{
				description: ''
				name: ''
				typ: codemodel.Type{
					symbol: ''
				}
			}
			description: ''
			params: [codemodel.Param{
				description: 'a name that the function will do nothing with'
				name: 'name'
				typ: codemodel.Type{
					symbol: 'string'
				}
			}]
			body: ''
			result: codemodel.Result{
				typ: codemodel.Type{
					symbol: 'void'
				}
				description: ''
				name: ''
			}
			has_return: false
		}), codemodel.CodeItem(codemodel.Struct{
			name: 'AnotherfileStruct0'
			fields: [codemodel.StructField{
				comments: []
				attrs: []
				name: 'param1'
				typ: codemodel.Type{
					symbol: 'string'
				}
			}, codemodel.StructField{
				comments: []
				attrs: []
				name: 'param2'
				typ: codemodel.Type{
					symbol: 'int'
				}
			}]
		}), codemodel.CodeItem(codemodel.Function{
			name: 'anotherfile_func2'
			receiver: codemodel.Param{
				description: ''
				name: ''
				typ: codemodel.Type{
					symbol: ''
				}
			}
			description: ''
			params: [codemodel.Param{
				description: 'configuration for anotherfile_func2'
				name: 'config'
				typ: codemodel.Type{
					symbol: 'AnotherfileStruct0'
				}
			}]
			body: ''
			result: codemodel.Result{
				typ: codemodel.Type{
					symbol: 'void'
				}
				description: ''
				name: ''
			}
			has_return: false
		}), codemodel.CodeItem(codemodel.Struct{
			name: 'AnotherfileStruct1'
			fields: [codemodel.StructField{
				comments: []
				attrs: []
				name: 'param'
				typ: codemodel.Type{
					symbol: 'string'
				}
			}]
		}), codemodel.CodeItem(codemodel.Function{
			name: 'anotherfile_func3'
			receiver: codemodel.Param{
				description: ''
				name: ''
				typ: codemodel.Type{
					symbol: ''
				}
			}
			description: ''
			params: [codemodel.Param{
				description: ''
				name: 'param1'
				typ: codemodel.Type{
					symbol: 'string'
				}
			}, codemodel.Param{
				description: ''
				name: 'param2'
				typ: codemodel.Type{
					symbol: 'string'
				}
			}]
			body: ''
			result: codemodel.Result{
				typ: codemodel.Type{
					symbol: 'AnotherfileStruct1'
				}
				description: 'a FileStruc1 struct filled in with params 1 and 2'
				name: 'the created filestruct1'
			}
			has_return: false
		})
	],
	'subfile.v': [
		codemodel.CodeItem(codemodel.Function{
			name: 'subfile_func0'
			receiver: codemodel.Param{
				description: ''
				name: ''
				typ: codemodel.Type{
					symbol: ''
				}
			}
			description: ''
			params: []
			body: ''
			result: codemodel.Result{
				typ: codemodel.Type{
					symbol: 'void'
				}
				description: ''
				name: ''
			}
			has_return: false
		}), codemodel.CodeItem(codemodel.Function{
			name: 'subfile_func1'
			receiver: codemodel.Param{
				description: ''
				name: ''
				typ: codemodel.Type{
					symbol: ''
				}
			}
			description: ''
			params: [codemodel.Param{
				description: 'a name that the function will do nothing with'
				name: 'name'
				typ: codemodel.Type{
					symbol: 'string'
				}
			}]
			body: ''
			result: codemodel.Result{
				typ: codemodel.Type{
					symbol: 'void'
				}
				description: ''
				name: ''
			}
			has_return: false
		}), codemodel.CodeItem(codemodel.Struct{
			name: 'SubfileStruct0'
			fields: [codemodel.StructField{
				comments: []
				attrs: []
				name: 'param1'
				typ: codemodel.Type{
					symbol: 'string'
				}
			}, codemodel.StructField{
				comments: []
				attrs: []
				name: 'param2'
				typ: codemodel.Type{
					symbol: 'int'
				}
			}]
		}), codemodel.CodeItem(codemodel.Function{
			name: 'subfile_func2'
			receiver: codemodel.Param{
				description: ''
				name: ''
				typ: codemodel.Type{
					symbol: ''
				}
			}
			description: ''
			params: [codemodel.Param{
				description: 'configuration for subfile_func2'
				name: 'config'
				typ: codemodel.Type{
					symbol: 'SubfileStruct0'
				}
			}]
			body: ''
			result: codemodel.Result{
				typ: codemodel.Type{
					symbol: 'void'
				}
				description: ''
				name: ''
			}
			has_return: false
		}), codemodel.CodeItem(codemodel.Struct{
			name: 'SubfileStruct1'
			fields: [codemodel.StructField{
				comments: []
				attrs: []
				name: 'param'
				typ: codemodel.Type{
					symbol: 'string'
				}
			}]
		}), codemodel.CodeItem(codemodel.Function{
			name: 'subfile_func3'
			receiver: codemodel.Param{
				description: ''
				name: ''
				typ: codemodel.Type{
					symbol: ''
				}
			}
			description: ''
			params: [codemodel.Param{
				description: ''
				name: 'param1'
				typ: codemodel.Type{
					symbol: 'string'
				}
			}, codemodel.Param{
				description: ''
				name: 'param2'
				typ: codemodel.Type{
					symbol: 'string'
				}
			}]
			body: ''
			result: codemodel.Result{
				typ: codemodel.Type{
					symbol: 'SubfileStruct1'
				}
				description: 'a FileStruc1 struct filled in with params 1 and 2'
				name: 'the created filestruct1'
			}
			has_return: false
		})
	]
	'file.v': []CodeItem{}
}

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
		eprintln('\nTEST: test_vparse_exclude_dirs\n')
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
		eprintln('\nTEST: test_vparse_exclude_files\n')
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
		eprintln('\nTEST: test_vparse_only_pub\n')
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