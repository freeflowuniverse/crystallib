module flatdir

// anotherfile_func0 is the first function of file
fn anotherfile_func0() {}

// anotherfile_func1 is the second function of file
// - name: a name that the function will do nothing with
pub fn anotherfile_func1(name string) {}

// AnotherfileStruct0 defines the configuration params of anotherfile_func2
@[params]
pub struct AnotherfileStruct0 {
	param1 string //
	param2 int    //
}

// anotherfile_func2 is the third function of the file
// - config: configuration for anotherfile_func2
pub fn anotherfile_func2(config AnotherfileStruct0) {}

pub struct AnotherfileStruct1 {
	param string
}

// anotherfile_func3 is the fourth function of the file
// is does something with param1 and param2 and creates AnotherfileStruct1
// returns the created filestruct1, a FileStruc1 struct filled in with params 1 and 2
pub fn anotherfile_func3(param1 string, param2 string) AnotherfileStruct1 {
	return AnotherfileStruct1{
		param: param1 + param2
	}
}
