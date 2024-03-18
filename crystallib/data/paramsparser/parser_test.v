module paramsparser

fn test_parse_list() ! {
	mut params := parse("list1: ['Kiwi']")!
	assert params == Params{
		params: [Param{
			key: 'list1'
			value: "['Kiwi']"
			comment: ''
		}]
		args: []
		comments: []
	}
	params = parse("list2: ['Apple', 'Banana']")!
	assert params == Params{
		params: [
			Param{
				key: 'list2'
				value: "['Apple', 'Banana']"
				comment: ''
			},
		]
		args: []
		comments: []
	}
}
