module test

// subfile_func0 is the first function of file
fn subfile_func0() {}

// subfile_func1 is the second function of file
// - name: a name that the function will do nothing with
pub fn subfile_func1(name string) {}

// SubfileStruct0 defines the configuration params of subfile_func2
[params]
pub struct SubfileStruct0 {
	param1 string //
	param2 int    //
}

// subfile_func2 is the third function of the file
// - config: configuration for subfile_func2
pub fn subfile_func2(config SubfileStruct0) {}

pub struct SubfileStruct1 {
	param string
}

// subfile_func3 is the fourth function of the file
// is does something with param1 and param2 and creates SubfileStruct1
// returns the created filestruct1, a FileStruc1 struct filled in with params 1 and 2
pub fn subfile_func3(param1 string, param2 string) SubfileStruct1 {
	return SubfileStruct1{
		param: param1 + param2
	}
}
