module markdowndocs

import os
import pathlib

//is a line parser

// error while parsing
struct ParserError {
mut:
	error  string
	linenr int
	line   string
}

struct Parser {
mut:
	linenr int
	lines  []string
	errors []ParserError
	atstart bool = true //if true means we start from scratch, looking for new elements
}

pub fn parser_new(path string)! Parser{
	if !os.exists(path) {
		return error("path: '${path}' does not exist, cannot parse.")
	}
	mut parser:=Parser{}
	mut content := os.read_file(path) or { panic('Failed to load file ${path}') }
	parser.lines = content.split_into_lines()
	parser.lines.map(it.replace('\t', '    ')) // remove the tabs
	parser.linenr = 0
	return parser
}

// return a specific line
fn (mut parser Parser) error_add(msg string) {
	parser.errors << ParserError{
		error: msg
		linenr: parser.linenr
		line: parser.line_current()
	}
}

// return a specific line
fn (mut parser Parser) line(nr int) !string {
	if nr < 0 {
		return error('before file')
	}
	if nr == parser.lines.len || nr > parser.lines.len {
		return error('end of file')
	}
	return parser.lines[nr]
}

// get current line
// will return error if out of scope
fn (mut parser Parser) line_current() string {
	return parser.line(parser.linenr) or { panic(err) }
}

// get next line, if end of file will return **EOF**
fn (mut parser Parser) line_next() string {
	if parser.eof() {
		return '**EOF**'
	}
	return parser.line(parser.linenr + 1) or { panic(err) }
}

// if at start will return  **EOF**
fn (mut parser Parser) line_prev() string {
	if parser.linenr - 1 < 0 {
		return '**EOF**'
	}
	return parser.line(parser.linenr - 1) or { panic(err) }
}

// move further
fn (mut parser Parser) next() {
	parser.linenr += 1
}

// move further and reset the state
fn (mut parser Parser) next_start() {
	parser.atstart = true
	parser.next()
}



// return true if end of file
fn (mut parser Parser) eof() bool {
	if parser.linenr == parser.lines.len || parser.linenr > parser.lines.len {
		return true
	}
	return false
}





// // walk backwards over the objects, if equal with what we have we keep on walking back
// // if we find one which is same type as specified will return
// fn (mut parser Parser) item_get_previous(tocheck_ string, ignore_ []string) &DocItem {
// 	mut ignore := ignore_.clone()
// 	mut itemnr := parser.doc.items.len - 1
// 	mut itemname_start := parser.doc.items[itemnr].type_name().all_after_last('.').to_lower()
// 	tocheck := tocheck_.to_lower().trim_space()
// 	// walk backwards till previous state is not the current
// 	// the original itemname
// 	// print(" .. previous $tocheck $ignore")
// 	if itemname_start == tocheck {
// 		// print(" *R0.$itemname_start\n")
// 		return &parser.doc.items[itemnr]
// 	}
// 	for {
// 		mut itemname_current := parser.doc.items[itemnr].type_name().all_after_last('.').to_lower()
// 		if itemnr == 0 {
// 			// print(" *B.$itemname_current")
// 			break
// 		}
// 		if itemname_current in ignore {
// 			itemnr -= 1
// 			// print(" *I.$itemname_current")
// 			continue
// 		}
// 		if itemname_current == tocheck {
// 			// print(" *R.$itemname_current\n")
// 			return &parser.doc.items[itemnr]
// 		}
// 		// print(" *B.$itemname_current")
// 		break
// 	}
// 	// print(" *NO\n")
// 	return &Doc{}
// }

// // go further over lines, see if we can find one which has one of the to_find items in but we didn't get tostop item before
// fn (mut parser Parser) look_forward_find(tofind []string, tostop []string) bool {
// 	mut found := false
// 	for line in parser.lines[parser.linenr + 1..parser.lines.len] {
// 		// println(" +++ " +line)
// 		for item in tostop {
// 			if line.trim_space().starts_with(item) {
// 				// println("found:$found")
// 				return found
// 			}
// 		}
// 		for item2 in tofind {
// 			if line.trim_space().starts_with(item2) {
// 				found = true
// 			}
// 		}
// 	}
// 	// println("NOTFOUND")
// 	return false
// }
