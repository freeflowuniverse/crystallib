module texttools

fn test_istest1() {
	assert is_int('0000')
	assert is_int('999')
	assert is_int('0')
	assert is_int('9')
	assert is_int('00 00') == false
	assert is_int('00a00') == false

	assert is_upper_text('A')
	assert is_upper_text('Z')
	assert is_upper_text('AAZZZZAAA')
	assert is_upper_text('z') == false
	assert is_upper_text('AAZZZZaAA') == false
	assert is_upper_text('AAZZZZ?AA') == false
	assert is_upper_text("AAZZZZ'AA") == false
}
