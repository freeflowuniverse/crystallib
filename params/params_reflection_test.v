module params

struct TestStruct {
    name string
    number int
    yesno bool
    liststr []string
    listint []int
}

struct TestStruct2 {
    name []string
    number int
    yesno bool
    liststr []string
    listint []int
}

// all unsuppported
struct TestStruct3 {
    name []u8
    number f64
    yesno []bool
    liststr [][]string
    listint [][]int
}

fn test_decode() {
    test := TestStruct {
        name: 'test'
        number: 2
        yesno: true
        liststr: ['one', 'two']
        listint: [1, 2]
    }

    params := Params {
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
            value:'one, two'
        }, Param{
            key: 'listint'
            value:'1, 2'
        }]
    }

    decoded := params.decode[TestStruct]()!
    assert decoded == test

	decoded2 := params.decode[TestStruct2]()!
	assert typeof(decoded2.name) != typeof(decoded.name)

	// Check fails with correct error provided unsupported type
	if decoded3 := params.decode[TestStruct3]() {
		assert false
	}
	else {
		assert err.msg == 'Unsupported type: Params encoding and decoding for generic types only supports the following types:\nstring, int, bool, []string, []int.'
	}
}

fn test_encode() {
    test := TestStruct {
        name: 'test'
        number: 2
        yesno: true
        liststr: ['one', 'two']
        listint: [1, 2]
    }

    params := Params {
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
            value:'one, two'
        }, Param{
            key: 'listint'
            value:'1, 2'
        }]
    }

    encoded := encode[TestStruct](test)!
    assert encoded == params
}
