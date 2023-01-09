module markdowndocs

import os
import pathlib

//is a char parser

// error while parsing
struct ParserCharError {
mut:
	error  string
	charnr int
}

struct ParserCharGroup {
mut:
	charnr int
	content  string
}
struct ParserChar {
mut:
	charnr int
	chars  string
	errors []ParserCharError
	atstart bool = true //if true means we start from scratch, looking for new elements
	group ParserCharGroup
}

pub fn parser_char_new(path string)! ParserChar{
	if !os.exists(path) {
		return error("path: '${path}' does not exist, cannot parse.")
	}
	mut parser:=ParserChar{group:ParserCharGroup{}}
	mut content := os.read_file(path) or { panic('Failed to load file ${path}') }
	parser.chars = content
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
	if nr == parser.chars.len || nr > parser.chars.len {
		return error('end of file')
	}
	return parser.chars[nr]
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

//create a group, can be e.g. a link
fn (mut parser ParserChar) group_new(char string) {
	parser.group = ParserCharGroup{charnr:parser.charnr}
}

fn (mut parser ParserChar) group_add() {
	parser.group.content += parser.char_current()
}

//check if starting from position the next is the exact string (starts at position itself)
fn (mut parser ParserChar) text_next_is(tofind string) bool{
	text := parser.substr(parser.nr,parser.nr+tofind.len)
	return text == tofind
}

//check if previous text was, current possition does not count
fn (mut parser ParserChar) text_previous_was(tofind string) bool{
	text := parser.substr(parser.nr-tofind-1.len,parser.nr-1)
	return text == tofind
}



// move further
fn (mut parser ParserChar) next() {
	parser.charnr += 1
}

// move further and reset the state
fn (mut parser ParserChar) next_start() {
	parser.atstart = true
	parser.next()
}

// return true if end of file
fn (mut parser ParserChar) eof() bool {
	if parser.charnr == parser.chars.len || parser.charnr > parser.chars.len {
		return true
	}
	return false
}


