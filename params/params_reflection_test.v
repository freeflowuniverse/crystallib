module params

struct TestStruct {
    name string
    number int
    yesno bool
    liststr []string
    listint []int
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
