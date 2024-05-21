module codeparser

// const example_txt = "
// Example: Get pet example.
// assert some_function('input_string') == 'output_string'
// "


// // "examples": [
// //         {
// //           "name": "getPetExample",
// //           "description": "get pet example",
// //           "params": [
// //             {
// //               "name": "petId",
// //               "value": 7
// //             }
// //           ],
// //           "result": {
// //             "name": "getPetExampleResult",
// //             "value": {
// //               "name": "fluffy",
// //               "tag": "poodle",
// //               "id": 7
// //             }
// //           }
// //         }

// fn test_parse_example() ! {
// 	example := parse_example(example_txt)
// 	panic('example ${example}')
// }