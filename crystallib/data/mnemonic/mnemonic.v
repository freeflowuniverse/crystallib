module mnemonic

import crypto.rand
import crypto.sha256
import math.big
import strings
import strconv

// pure v implementation of BIP39 following specification from
// https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki

pub struct BIP39 {
mut:
	wordlist string
	words    []string
}

pub fn new() !BIP39 {
	mut b := BIP39{
		// only english supported for now
		wordlist: 'english'
	}

	embedded_english := $embed_file('english.txt', .zlib)
	b.words = embedded_english.to_string().split('\n')

	// remove last empty line
	if b.words.len == 2049 {
		b.words.pop()
	}

	// ensure our wordlist is sane
	if b.words.len != 2048 {
		return error('could not load wordlist')
	}

	return b
}

//
// parse mnemonic
//

pub fn (b BIP39) to_entropy(mnemonics string) ![]u8 {
	words := mnemonics.split(' ')
	mut ms := words.len

	// only supports 12, 15, 18, 21 and 24 words.
	if (ms in [12, 15, 18, 21, 24]) == false {
		return error('mnemonics out of range, only [12, 15, 18, 21 or 24] words supported')
	}

	/* table from specification, to match entropy, checksum and words
	
	ENT = entropy length in bits
	CS = checksum length in bits
	MS = number of words

    |  ENT  | CS | ENT+CS |  MS  |
    +-------+----+--------+------+
    |  128  |  4 |   132  |  12  |
    |  160  |  5 |   165  |  15  |
    |  192  |  6 |   198  |  18  |
    |  224  |  7 |   231  |  21  |
    |  256  |  8 |   264  |  24  |
	*/

	// extract entropy and checksum size, starting at 12 words
	// (we can't go lower)
	// mut cs := 4
	mut ent := 128
	mut i := ms

	// go further til we reach the minimum (nothing to do for 12 words)
	for i > 12 {
		// cs += 1
		ent += 32
		i -= 3
	}

	// starting from an empty string
	mut buffer := ''

	for word in words {
		index := b.words.index(word)
		if index < 0 {
			return error("unexpected word '${word}' found")
		}

		// building binary representation of the index value
		// in order to always have 11 bits, we use bit_len to know
		// how many bits will be returned with bin_str() and add missing
		// zeros as prefix
		inter := big.integer_from_int(index) // convert to Integer
		repr := inter.bit_len()

		// pad with missing zero to reach 11 bits
		buffer += strings.repeat_string('0', 11 - repr)

		// append the binary representation
		buffer += inter.bin_str()
	}

	// buffer is now a string representing binary value of the mnemonic (entropy + checksum)
	mut final := []u8{}

	// let's convert this binary string to bytes now
	for a in 0 .. (ent / 8) {
		start := a * 8
		final << u8(strconv.parse_uint(buffer[start..start + 8], 2, 8)!)
	}

	// remaining bits are checksum (we don't use them here)
	// TODO: verify checksum

	// entropy restored
	return final
}

//
// create mnemonic
//

pub fn (b BIP39) generate_entropy(size int) ![]u8 {
	if size < 128 || size > 256 {
		return error('size out of range (min 128, max 256)')
	}

	if size % 32 != 0 {
		return error('size must be a multiple of 32 bits')
	}

	// size can only be 128, 160, 192, 224, 256
	entropy := rand.bytes(size / 8)!

	return entropy
}

pub fn (b BIP39) compute_checksum(entropy []u8) string {
	// we assume entropy length is valid

	// computing checksum length
	cs := (entropy.len * 8) / 32

	// computing sha256 of the entropy
	entro256 := sha256.sum(entropy)

	// convert the first byte to Integer
	first := big.integer_from_u32(entro256[0])

	// adding leading zero if missing then adding
	// binary bits
	repr := first.bit_len()

	mut source := strings.repeat_string('0', 8 - repr)
	source += first.bin_str()

	// source is always 8 bits now
	// truncate to expected length

	return source[0..cs]
}

pub fn (b BIP39) generate_binary_from_entropy(entropy []u8) !string {
	checksum := b.compute_checksum(entropy)

	// println(entropy.hex())
	// println(checksum)

	mut buffer := ''

	for i in 0 .. entropy.len {
		segment := big.integer_from_u32(entropy[i])

		// converting each byte to it's binary representation
		// into the main buffer
		repr := segment.bit_len()
		buffer += strings.repeat_string('0', 8 - repr)

		// if byte is zero, padding already filled all the zeros
		if entropy[i] > 0 {
			buffer += segment.bin_str()
		}
	}

	// adding the checksum to the buffer
	// buffer will now be (entropy + checksum) in the table (see to_entropy)
	buffer += checksum

	return buffer
}

pub fn (b BIP39) to_mnemonic(source []u8) ![]string {
	binary := b.generate_binary_from_entropy(source)!
	mut words := []string{}

	for i in 0 .. (binary.len / 11) {
		start := i * 11

		// converting the next 11 bits to it's integer value
		// and mapping the corresponding word in wordlist
		value := binary[start..start + 11]
		index := strconv.parse_int(value, 2, 16)!

		words << b.words[index]
	}

	return words
}

pub fn (b BIP39) generate(size int) ![]string {
	entropy := b.generate_entropy(size)!
	return b.to_mnemonic(entropy)
}

//
// seed
//

pub fn (b BIP39) to_seed(words string, passphrase string) ![]u8 {
	// derivated := pbkdf2(.sha512, words, "mnemonic" + passphrase, 2048, 512)
	// return derivated

	return error('not implemented')
}

//
// small debug and example
//

pub fn debug() !bool {
	m := new()!

	words := m.generate(128)!
	println(words)

	native := m.generate_entropy(224)!
	wordsx := m.to_mnemonic(native)!
	println(wordsx)

	back := m.to_entropy(words.join(' '))!
	println(back.hex())

	return true
}
