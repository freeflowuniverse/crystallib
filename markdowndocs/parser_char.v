module markdowndocs

import os

// is a char parser

// error while parsing
struct ParserCharError {
mut:
	error  string
	charnr int
}

struct ParserChar {
mut:
	charnr  int
	chars   string
	errors  []ParserCharError
}

pub fn parser_char_new_path(path string) !ParserChar {
	if !os.exists(path) {
		return error("path: '${path}' does not exist, cannot parse.")
	}
	mut parser := ParserChar{
	}
	mut content := os.read_file(path) or { panic('Failed to load file ${path}') }
	parser.chars = content
	parser.charnr = 0
	return parser
}

pub fn parser_char_new_text(text string) ParserChar {
	mut parser := ParserChar{
	}
	parser.chars = text
	parser.charnr = 0
	return parser
}

// return a specific char
fn (mut parser ParserChar) error_add(msg string) {
	parser.errors << ParserCharError{
		error: msg
		charnr: parser.charnr
	}
}

// return a specific char
fn (mut parser ParserChar) char(nr int) !string {
	if nr < 0 {
		return error('before file')
	}
	if parser.eof() {
		return error('end of charstring')
	}
	return parser.chars.substr(parser.charnr,parser.charnr+1)
}

// get current char
// will return error if out of scope
fn (mut parser ParserChar) char_current() string {
	return parser.char(parser.charnr) or { panic(err) }
}

// get next char, if end of file will return empty char
fn (mut parser ParserChar) char_next() string {
	if parser.eof() {
		return ''
	}
	return parser.char(parser.charnr + 1) or { panic(err) }
}

// if at start will return an empty char
fn (mut parser ParserChar) char_prev() string {
	if parser.charnr - 1 < 0 {
		return ''
	}
	return parser.char(parser.charnr - 1) or { panic(err) }
}


// check if starting from position +1 , current not in
fn (mut parser ParserChar) text_next_is(tofind string) bool {
	startpos:=parser.charnr+1
	if startpos >  parser.chars.len{
		return false
	}
	text := parser.chars.substr(startpos, startpos + tofind.len).replace("\n","\\n")
	print(" -NT($tofind):'$text'")
	return text == tofind
}

//starts from position itself
fn (mut parser ParserChar) text_is(tofind string) bool {
	startpos:=parser.charnr
	if startpos >  parser.chars.len{
		return false
	}
	text := parser.chars.substr(startpos, startpos + tofind.len).replace("\n","\\n")
	print(" -NT($tofind):'$text'")
	return text == tofind
}


// check if previous text was, current possition does not count
fn (mut parser ParserChar) text_previous_is(tofind string) bool {
	startpos:=parser.charnr - tofind.len
	if startpos <0 {
		return false
	}
	text := parser.chars.substr(startpos, startpos + tofind.len).replace("\n","\\n")
	print(" -PT($tofind):'$text'")
	return text == tofind
}

//same as text_previous_is but includes the current position
fn (mut parser ParserChar) text_last_is(tofind string) bool {
	startpos:=parser.charnr - tofind.len +1
	if startpos <0 {
		return false
	}
	text := parser.chars.substr(startpos, startpos + tofind.len).replace("\n","\\n")
	print(" -LT($tofind):'$text'")
	return text == tofind
}


// move further
fn (mut parser ParserChar) next() {
	// print(parser.char_current())
	parser.charnr += 1
	// if !parser.eof() {
	// 	print(parser.char_current())
	// }
}

// return true if end of file
fn (mut parser ParserChar) eof() bool {
	if parser.charnr > parser.chars.len - 1 {
		return true
	}
	return false
}
