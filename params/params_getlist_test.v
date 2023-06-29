module params

fn test_get_list_single_quotes() {
	testparams := Params{
		params: [
			Param{
				key: 'mylist'
				value: '[\'A\',\'A\',\'A\',\'A\']'
			},
		]
	}
	list := testparams.get_list("mylist")!
	assert list == ['A', 'A', 'A', 'A']
}


fn test_get_list_double_quotes() {
	testparams := Params{
		params: [
			Param{
				key: 'mylist'
				value: '["A","A","A","A"]'
			},
		]
	}
	list := testparams.get_list("mylist")!
	assert list == ['A', 'A', 'A', 'A']
}

fn test_get_list_single_and_double_quotes() {
	testparams := Params{
		params: [
			Param{
				key: 'mylist'
				value: '["A","A",\'A\',"A"]'
			},
		]
	}
	list := testparams.get_list("mylist")!
	assert list == ['A', 'A', 'A', 'A']
}

fn test_get_list_double_quote_inside_single() {
	testparams := Params{
		params: [
			Param{
				key: 'mylist'
				value: '["A",\'"A"\',"A","A"]'
			},
		]
	}
	list := testparams.get_list("mylist")!
	assert list == ['A', '"A"', 'A', 'A']
}

fn test_get_list_invalid() {
	testparams := Params{
		params: [
			Param{
				key: 'mylist'
				value: '["A,"A","A","A"]'
			},
		]
	}
	list := testparams.get_list("mylist") or {
		// ok
		return
	}
	assert false, "expected get_list to throw an error"
}

fn test_get_list_u8() {
	testparams := Params{
		params: [
			Param{
				key: 'mylist'
				value: '[1, 5, 7, 2]'
			},
		]
	}
	list := testparams.get_list_u8("mylist")!
	assert list == [u8(1), u8(5), u8(7), u8(2)]
}

fn test_get_list_u32() {
	testparams := Params{
		params: [
			Param{
				key: 'mylist'
				value: '[1, 5, 7, 15148]'
			},
		]
	}
	list := testparams.get_list_u32("mylist")!
	assert list == [u32(1), u32(5), u32(7), u32(15148)]
}

fn test_get_list_u64() {
	testparams := Params{
		params: [
			Param{
				key: 'mylist'
				value: '[1, 5, 7, 15148]'
			},
		]
	}
	list := testparams.get_list_u64("mylist")!
	assert list == [u64(1), u64(5), u64(7), u64(15148)]
}

fn test_get_list_f64() {
	testparams := Params{
		params: [
			Param{
				key: 'mylist'
				value: '[1.5, 5.78, 7.478, 15148.4654]'
			},
		]
	}
	list := testparams.get_list_f64("mylist")!
	assert list == [1.5, 5.78, 7.478, 15148.4654]
}

fn test_get_list_int() {
	testparams := Params{
		params: [
			Param{
				key: 'mylist'
				value: '[1, -25, 165, -1484984]'
			},
		]
	}
	list := testparams.get_list_int("mylist")!
	assert list == [1, -25, 165, -1484984]
}