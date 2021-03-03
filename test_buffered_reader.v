module main

import io

pub struct StringReader {
	text string
mut:
	place int
}

fn imin(a int, b int) int {
	return if a < b { a } else { b }
}
fn (mut s StringReader) read(mut buf []byte) ?int {
	println(' - consumer buff len $buf.len ($s.place | ${imin(s.place + buf.len, s.text.len)} | $s.text.len)')
	if s.place >= s.text.len {
		// println('NONE')
		return none
	}
	println(" >> ${s.text[s.place..imin(s.place + buf.len, s.text.len)]}")
	nrread := copy(buf, s.text[s.place..imin(s.place + buf.len, s.text.len)].bytes())
	s.place += nrread
	return nrread
}

pub fn buffered_string_reader(s string) &io.BufferedReader {
	mut s2 := StringReader{
		text: s
	}
	return io.new_buffered_reader(reader: io.make_reader(s2), cap: 256)
}

fn do1() {
	println("TEST1")
	mut str := StringReader{
		text: 'Hello '
	}
	mut stream := io.new_buffered_reader(reader: io.make_reader(str), cap: 20)
	mut buff := []byte{len: 1}
	assert buff.len == 1
	for i in 0 .. 6 {
		z := stream.read(mut buff) or { -1 }
		println(' - reader buff len $buff.len ($i:$buff) | readresult: $z')
	}

}

fn do2() {
	println("\n'nTEST2: should be same but is not")
	mut stream := buffered_string_reader('Hello')
	mut buff := []byte{len: 1}
	assert buff.len == 1
	for i in 0 .. 8 {
		z := stream.read(mut buff) or { -1 }
		println(' - reader buff len $buff.len ($i:$buff) | readresult: $z')
	}

}


fn main() {
	do1()
	do2()

}