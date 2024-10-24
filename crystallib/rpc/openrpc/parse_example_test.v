module openrpc

import freeflowuniverse.crystallib.core.codemodel { Attribute, Struct, StructField, Type }

const example_txt = "
Example: Get pet example.
assert some_function('input_string') == 'output_string'
"

// "examples": [
//         {
//           "name": "getPetExample",
//           "description": "get pet example",
//           "params": [
//             {
//               "name": "petId",
//               "value": 7
//             }
//           ],
//           "result": {
//             "name": "getPetExampleResult",
//             "value": {
//               "name": "fluffy",
//               "tag": "poodle",
//               "id": 7
//             }
//           }
//         }

fn test_parse_example_pairing() ! {
	example := parse_example_pairing(openrpc.example_txt)!
	params := example.params or { panic('oop') }
	assert params.len == 1
	param0 := (params[0] as Example)
	assert param0.value or { panic('err') } == "'input_string'"
}

const test_struct = Struct{
	name: 'TestStruct'
	fields: [
		StructField{
			name: 'TestField'
			typ: Type{
				symbol: 'int'
			}
			attrs: [Attribute{
				name: 'example'
				arg: '21'
			}]
		},
	]
}

fn test_parse_struct_example() ! {
	example := parse_struct_example(openrpc.test_struct)
	// assert example.name == 'TestStructExample'
	// panic(example)
}
