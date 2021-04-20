module resp2

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
	// println(' - consumer buff len $buf.len ($s.place | ${imin(s.place + buf.len, s.text.len)} | $s.text.len)')
	if s.place >= s.text.len {
		// println('NONE')
		return none
	}
	nrread := copy(buf, s.text[s.place..imin(s.place + buf.len, s.text.len)].bytes())
	s.place += nrread
	return nrread
}

pub fn buffered_string_reader(s string) &io.BufferedReader {
	mut s2 := StringReader{
		text: s + ' '
	}
	return io.new_buffered_reader(reader: io.make_reader(s2), cap: 256)
}
