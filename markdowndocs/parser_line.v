module markdowndocs

// is a line parser

// error while parsing
struct ParserError {
mut:
	error  string
	linenr int
	line   string
}

struct Parser {
mut:
	doc    &Doc
	linenr int
	lines  []string
	errors []ParserError
	endlf  bool // if there is a linefeed or \n at end
}

fn parser_line_new(mut doc Doc) !Parser {
	mut parser := Parser{
		doc: doc
	}
	parser.doc.items << Paragraph{}
	parser.lines = doc.content.split_into_lines()
	if doc.content.ends_with('\n') {
		parser.endlf = true
	}
	parser.lines.map(it.replace('\t', '    ')) // remove the tabs
	parser.linenr = 0
	return parser
}

fn (mut parser Parser) lastitem() DocItem {
	return parser.doc.items.last()
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
fn (mut parser Parser) elementname() string {
	if parser.doc.items.len == 0 {
		return 'start'
	}
	return parser.doc.items.last().type_name().all_after_last('.').to_lower()
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
fn (mut parser Parser) next_start() {
	// means we need to add paragraph because we don't know what comes next
	if parser.doc.items.last() !is Paragraph {
		parser.doc.items << Paragraph{}
	}
	parser.next()
}

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
