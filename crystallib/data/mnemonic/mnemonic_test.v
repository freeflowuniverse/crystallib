import mnemonic
import strconv
import json

struct Vectors {
	english [][]string
}

fn entropy_from_hexstring(input string) ![]u8 {
	mut final := []u8{}

	for i in 0 .. (input.len / 2) {
		start := i * 2
		b := strconv.parse_uint(input[start..start + 2], 16, 8)!
		final << u8(b)
	}

	return final
}

fn test_python_vectors() {
	vectors := $embed_file('vectors.json')
	data := vectors.to_string()

	root := json.decode(Vectors, data) or {
		eprintln('Failed to decode json, error: ${err}')
		assert 'json parsing failed' == '${err}'
		return
	}

	m := mnemonic.new()!

	for vector in root.english {
		expected_entropy := vector[0]
		expected_words := vector[1]

		// load entropy from words
		entropy := m.to_entropy(expected_words)!
		assert entropy.hex() == expected_entropy

		// create words from entropy
		parsed := entropy_from_hexstring(expected_entropy)!
		words := m.to_mnemonic(parsed)!
		assert words.join(' ') == expected_words

		// TODO: implement seed
	}
}

fn test_loop() {
	m := mnemonic.new()!

	entropy := m.generate_entropy(224)!
	words := m.to_mnemonic(entropy)!
	wayback := m.to_entropy(words.join(' '))!

	assert wayback == entropy
}
