module markdown

import os
import freeflowuniverse.crystallib.texttools

//error while parsing
pub struct ParserError{
pub mut:
	error string
	linenr int
	line string
}

pub struct Parser{
pub mut:
	doc Doc
	linenr int
	lines []string
	errors []ParserError
}


//get a parser
pub fn get(path string ) ?Parser {
	mut parser:=Parser{}
	parser.file_parse(path)?
	return parser
}


//return a specific line
fn (mut parser Parser) error_add(msg string){
	parser.errors << ParserError{error:msg, linenr:parser.linenr, line: parser.line_current()}

}

//return a specific line
fn (mut parser Parser) line(nr int) ?string{
	if nr<0{
		return error("before file")
	}
	if nr == parser.lines.len || nr > parser.lines.len{
		return error("end of file")
	}
	return parser.lines[nr]
}


//get current line
//will return error if out of scope
fn (mut parser Parser) line_current() string{
	return parser.line(parser.linenr) or {panic(err)}
}

//get next line, if end of file will return **EOF**
fn (mut parser Parser) line_next() string{
	if parser.eof(){
		return "**EOF**"
	}
	return parser.line(parser.linenr+1) or {panic(err)}
}

//if at start will return  **EOF**
fn (mut parser Parser) line_prev() string{
	if parser.linenr-1 < 0 {
		return "**EOF**"
	}
	return parser.line(parser.linenr-1) or {panic(err)}
}

//move further
fn (mut parser Parser) next() {
	parser.linenr+=1
}

//move further and reset the state
fn (mut parser Parser) next_start() {
	if ! parser.state_check("docstart") {
		parser.doc.items << DocStart{}
	}
	parser.next()
}

fn (mut parser Parser) state() string {
	return parser.doc.items.last().type_name().all_after_last(".").to_lower()
}

//if state is this name will return true
fn (mut parser Parser) state_check(tocheck string) bool {
	if parser.state()==tocheck.to_lower().trim_space(){
		return true
	}	
	return false
}


//walk backwards over the objects, if equal with what we have we keep on walking back
//if we find one which is same type as specified will return
fn (mut parser Parser) item_get_previous(tocheck_ string, ignore_ []string) &DocItem {
	mut ignore := ignore_.clone()
	mut itemnr := parser.doc.items.len-1
	mut itemname_start := parser.doc.items[itemnr].type_name().all_after_last(".").to_lower()
	tocheck := tocheck_.to_lower().trim_space()
	//walk backwards till previous state is not the current
	//the original itemname
	// print(" .. previous $tocheck $ignore")
	if itemname_start==tocheck{
		// print(" *R0.$itemname_start\n")
		return &parser.doc.items[itemnr]
	}	
	for {
		mut itemname_current := parser.doc.items[itemnr].type_name().all_after_last(".").to_lower()		
		if itemnr==0{
			// print(" *B.$itemname_current")
			break
		}			
		if itemname_current in ignore{
			itemnr-=1
			// print(" *I.$itemname_current")
			continue
		}
		if itemname_current == tocheck{
			// print(" *R.$itemname_current\n")
			return &parser.doc.items[itemnr]
		}
		// print(" *B.$itemname_current")
		break
	}
	// print(" *NO\n")
	return &DocStart{}
}


//go further over lines, see if we can find one which has one of the to_find items in but we didn't get tostop item before
fn (mut parser Parser) look_forward_find(tofind []string, tostop []string) bool {
	mut found:=false
	for line in parser.lines[parser.linenr+1..parser.lines.len]{
		// println(" +++ " +line)
		for item in tostop{
			if line.trim_space().starts_with(item){
				// println("found:$found")
				return found
			}
		}
		for item2 in tofind{
			if line.trim_space().starts_with(item2){
				found=true
			}
		}
	}
	// println("NOTFOUND")
	return false
}


//return true if end of file
fn (mut parser Parser) eof() bool{
	if parser.linenr == parser.lines.len || parser.linenr > parser.lines.len{
		return true
	}
	return false
}

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT RELIALITIES



fn (mut parser Parser) file_parse(path string) ? {
	if !os.exists(path) {
		return error("path: '$path' does not exist, cannot parse.")
	}
	mut content := os.read_file(path) or { panic('Failed to load file $path') }
	parser.lines = content.split_into_lines()
	parser.lines.map(it.replace('\t', '    ')) //remove the tabs
	parser.linenr = 0

	parser.doc.items << DocStart{}
	// no need to process files which are not at least 2 chars
	for {

		mut llast := parser.doc.items.last()

		if parser.eof(){break} //go out of loop if end of file
		line := parser.line_current()
		println("line (${parser.state()}): '$line'")

		if mut llast is Comment{
			if llast.prefix == .short{
				if line.trim_space().starts_with('//'){	
					llast.content += line.all_after_first("//") + "\n"	
					parser.next()
					continue			
				}
				parser.doc.items << DocStart{} //make sure we restart from scratch because is not comment
			}else{
				if line.trim_space().ends_with('-->'){
					llast.content += line.all_before_last("-->") + "\n"	
					parser.next_start()
				}else{
					llast.content += line + "\n"	
					parser.next()
				}
				continue
			}
		}

		if mut llast is Action {
			if line.starts_with(' ') || line.starts_with('\t'){
				// starts with tab or space, means block continues for action
				llast.content += "$line\n"
			} else {
				parser.doc.items << DocStart{}
			}
			parser.next()
			continue			
		}
		
		if mut llast is CodeBlock {
			if line.starts_with('```') || line.starts_with('"""') || line.starts_with('\'\'\'') {
				parser.doc.items << DocStart{}
			}else{
				llast.content += "$line\n"
			}
			parser.next()
			continue			
		}



		if parser.state_check("docstart") || parser.state_check("paragraph"){

			if line.starts_with('!!') {
				parser.doc.items << Action{content:line.all_after_first("!!")}
				parser.next()
				continue
			}			

			//find codeblock or actions
			if line.starts_with('```') || line.starts_with('"""') || line.starts_with('\'\'\'') {
				parser.doc.items << CodeBlock{category:line.substr(3,line.len).to_lower().trim_space()}
				parser.next()
				continue
			}				

			//process headers
			if line.starts_with('######') {
				parser.error_add("header should be max 5 deep")
				parser.next_start()
				continue
			}
			if line.starts_with('#####') {
				parser.doc.items << Header{content:line.all_after_first("#####").trim_space(),depth:5}
				parser.next_start()
				continue
			}
			if line.starts_with('####') {
				parser.doc.items << Header{content:line.all_after_first("####").trim_space(),depth:4}
				parser.next_start()
				continue
			}
			if line.starts_with('###') {
				parser.doc.items << Header{content:line.all_after_first("###").trim_space(),depth:3}
				parser.next_start()
				continue
			}
			if line.starts_with('##') {
				parser.doc.items << Header{content:line.all_after_first("##").trim_space(),depth:2}
				parser.next_start()
				continue
			}
			if line.starts_with('#') {
				parser.doc.items << Header{content:line.all_after_first("#").trim_space(),depth:1}
				parser.next_start()
				continue
			}

			if line.trim_space().starts_with('//') {
				parser.doc.items << Comment{content:line.all_after_first("//").trim_space() + "\n",prefix:.short}
				parser.next()
				continue
			}			
			if  line.trim_space().starts_with('<!--') {
				parser.doc.items << Comment{content:line.all_after_first("<!--").trim_space() + "\n",prefix:.multi}
				parser.next()
				continue
			}			


		}

		if parser.state_check("paragraph") {
			parser.doc.items.last().content += line + "\n"	
		}else{
			parser.doc.items << Paragraph{content:line }
		}

		parser.next()
	}

	//remove DocStart items
	mut nrs := []int{}
	mut nr := 0
	for item in parser.doc.items{
		if item is DocStart{
			nrs<<nr
		}
		if item is Paragraph{
			if item.content.trim_space() == ""{
				nrs<<nr
			}
		}		
		nr+=1
	}
	for nr2 in nrs.reverse(){
		parser.doc.items.delete(nr2)
	}

	parser.doc.process()?
}