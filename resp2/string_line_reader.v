module resp2

struct StringLineReader {
	data []byte
	y    int
mut:
	x int
}

pub fn new_line_reader(data []byte) StringLineReader {
	return StringLineReader{
		data: data
		y: data.len
	}
}

fn (mut r StringLineReader) read_line() ?[]byte {
	mut out := []byte{}
	mut c := ''.bytes()
	for {
		if r.x >= r.y {
			return none
		}
		c = [r.data[r.x]]
		if c == '\t'.bytes() {
			c = ' '.bytes()
		}
		if c == '\r'.bytes() {
			r.x++
			continue
		}
		if c == '\n'.bytes() {
			r.x++
			return out
		}
		out << c
		r.x++
	}
	return error('should not get here')
}

fn (mut r StringLineReader) read(x int) ?[]byte {
	mut out := []byte{}
	for _ in 0 .. x {
		if r.x > r.y - 1 {
			return none
		}
		// println(r.x)
		out << r.data[r.x]
		r.x++
	}
	return out
}

fn (mut r StringLineReader) reset() {
	r.x = 0
}
