module paramsparser

struct TestStruct {
	name    string
	number  int
	yesno   bool
	liststr []string
	listint []int
	listbool []bool
	child TestChild
}

struct TestChild {
	child_name string
	child_number  int
	child_yesno   bool
	child_liststr []string
	child_listint []int
	child_listbool []bool
}

const test_struct = TestStruct{
	name: 'test'
	number: 2
	yesno: true
	liststr: ['one', 'two']
	listint: [1, 2]
	child: TestChild{
		child_name: 'test_child'
		child_number: 3
		child_yesno: false
		child_liststr: ['three', 'four']
		child_listint: [3, 4]
	}
}

const test_params = Params{
	params: [Param{
		key: 'name'
		value: 'test'
	}, Param{
		key: 'number'
		value: '2'
	}, Param{
		key: 'yesno'
		value: 'true'
	}, Param{
		key: 'liststr'
		value: 'one,two'
	}, Param{
		key: 'listint'
		value: '1,2'
	}, Param{
		key: 'child'
		value: Params{
			params: [Param{
				key: 'child_name'
				value: 'test_child'
			}, Param{
				key: 'child_number'
				value: '3'
			}, Param{
				key: 'child_yesno'
				value: 'false'
			}, Param{
				key: 'child_liststr'
				value: 'three,four'
			}, Param{
				key: 'child_listint'
				value: '3,4'
			}]
		}.export()
	}]
}

fn test_decode() {
	decoded := test_params.decode[TestStruct]()!
	assert decoded == test_struct
}

fn test_encode() {
	encoded := encode[TestStruct](test_struct)!
	// println(en)
	assert encoded == test_params
}