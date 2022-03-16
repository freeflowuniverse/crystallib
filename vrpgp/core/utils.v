module core

pub fn cu8_to_vbytes(ptr &u8, l u64) []byte {
	mut res := []byte{}
	for _ in 0 .. l {
		res << byte(unsafe { *ptr })
		unsafe {
			ptr++
		}
	}
	return res
}
// no need for this function. just use "string".bytes()
pub fn str_to_bytes(s string) []byte {
	mut res := []byte{}
	for c in s {
		res << byte(c)
	}
	return res
}
