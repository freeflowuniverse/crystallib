module parsers

import freeflowuniverse.crystallib.data.markdownparser.elements
// is a line parser, useful to quickly parse a file in any format as long as it is line based

// error while parsing
struct ParserError {
mut:
	error  string
	linenr int
	line   string
}

struct Parser {
mut:
	doc    &elements.Doc
	linenr int
	lines  []string
	errors []ParserError
	endlf  bool // if there is a linefeed or \n at end
}

fn parser_line_new(mut doc elements.Doc) !Parser {
	mut parser := Parser{
		doc: doc
	}
	doc.paragraph_new('')
	parser.lines = doc.content.split_into_lines()
	if doc.content.ends_with('\n') {
		parser.endlf = true
	}
	parser.lines = parser.lines.map(it.replace('\t', '    ')) // remove the tabs
	parser.linenr = 0
	return parser
}

fn (mut parser Parser) lastitem() !elements.Element {
	return parser.doc.last()!
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
	if parser.eof() {
		return error('end of file')
	}
	return parser.lines[nr]
}

// get current line
// will return error if out of scope
fn (mut parser Parser) line_current() string {
	return parser.line(parser.linenr) or { panic(err) }
}

// get name of the element
fn (mut parser Parser) elementname() !string {
	if parser.doc.children.len == 0 {
		return 'start'
	}
	return parser.doc.last()!.type_name().all_after_last('.').to_lower()
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
	// println("line old (${parser.elementname()}): '${parser.line_current()}'")	
	parser.linenr += 1
	// if ! parser.eof(){
	// 	println("line new (${parser.elementname()}): '${parser.line_current()}'")	
	// }
}

// move further and reset the state
fn (mut parser Parser) next_start() ! {
	// means we need to add paragraph because we don't know what comes next
	if parser.doc.last()! !is elements.Paragraph {
		parser.doc.paragraph_new('')
	}
	parser.next()
}

fn (mut parser Parser) ensure_last_is_paragraph() ! {
	if parser.doc.last()! !is elements.Paragraph {
		parser.doc.paragraph_new('')
	}
}

// fn (mut parser Parser) append_paragraph() {
// 	 elements.paragraph_new(parent:parser.doc)
// }

// return true if end of file
fn (mut parser Parser) eof() bool {
	if parser.linenr > (parser.lines.len - 1) {
		return true
	}
	return false
}

fn (mut parser Parser) next_is_eof() bool {
	if parser.linenr > (parser.lines.len - 2) {
		return true
	}
	return false
}
