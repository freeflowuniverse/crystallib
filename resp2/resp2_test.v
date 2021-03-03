module resp2

import io

fn test_1() {
	mut rv := RValue(RError{
		value: 'my error'
	})
	println(rv.encode())

	rv = RValue(RArray{
		values: [RValue(RError{
			value: 'my error'
		}), RValue(RInt{
			value: 100
		})]
	})
	println(rv.encode())

	rv = r_list_string(['a', 'b', 'c'])
	println(rv.encode())
}

fn test_buffered_reader1() {
	mut stream := buffered_string_reader('Hello')
	mut buff := []byte{len: 1}
	assert buff.len == 1
	for i in 0 .. 8 {
		z := stream.read(mut buff) or { -1 }
		println(' - reader buff len $buff.len ($i:$buff) | readresult: $z')
	}
	panic('s')
}

// fn test_buffered_reader2() {
// 	mut str := StringReader{
// 		text: 'Hello '
// 	}
// 	mut stream := io.new_buffered_reader(reader: io.make_reader(str), cap: 256)
// 	mut buff := []byte{len: 1}
// 	assert buff.len == 1
// 	for i in 0 .. 8 {
// 		z := stream.read(mut buff) or { -1 }
// 		println(' - reader buff len $buff.len ($i:$buff) | readresult: $z')
// 	}

// 	panic('s')

	
// }
