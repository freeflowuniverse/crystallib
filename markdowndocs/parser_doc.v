module markdowndocs

import pathlib

struct Line{
	content string
}

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT RELIALITIES
fn doc_parse(path string) !Doc {
	path2 := pathlib.get_file(path, false)!
	mut doc:=Doc{path:path2}
	mut parser:=parser_new(path)!
	
	// no need to process files which are not at least 2 chars
	for {
		if parser.eof() {
			break
		}

		this_line := parser.line_current()
		line := Line{content: this_line}

		if line.is_heading(){
			heading_line := line.get_header()
			doc.items << heading_line
			parser.next_start()
			continue
		}

		if line.is_codeblock(){
			mut codeblock := line.get_codeblock()
			for{
				parser.next()
				new_line := parser.line_current()
				if new_line.starts_with("'''") || 
					new_line.starts_with('"""') || 
					new_line.starts_with("```"){
					break
				} else {
					codeblock.content += "\n" + new_line
				}
			}
			doc.items << codeblock
			parser.next_start()
			continue
		}

		if line.is_comment(){
			mut comment_line := line.get_comment()
			match comment_line.prefix{
				.multi{
					// Searching for the end of the comment.
					for{
						parser.next()
						new_line := parser.line_current()
						if new_line.starts_with("-->") || new_line.ends_with("-->"){
							break
						} else {
							comment_line.content += "\n" + new_line
						}
					}
				}
				.short{}
			}
			doc.items << comment_line
			parser.next_start()
			continue
		}
		parser.next()
	}

	doc.process()!
	return doc
}

fn (lin Line)is_codeblock()bool{
	if lin.content.starts_with("```") || 
		lin.content.starts_with("'''") || 
		lin.content.starts_with('"""') {
		return true
	}
	return false
}

fn (lin Line)get_codeblock()CodeBlock{
	return CodeBlock{
		category: lin.content.substr(3, lin.content.len).to_lower().trim_space()
		content: ""
	}
}

fn (lin Line)is_heading()bool{
	if lin.content.starts_with('#') || 
		lin.content.starts_with('##') || 
		lin.content.starts_with('###')|| 
		lin.content.starts_with('####') || 
		lin.content.starts_with('#####'){
		return true
	}
	return false
}

fn (lin Line)is_comment()bool{
	if lin.content.starts_with('<!--') || lin.content.starts_with('//'){
		return true
	}
	return false
}

fn (lin Line)get_comment()Comment{
	mut singleline := false
	mut prefix := CommentPrefix.short
	mut content := ""

	if lin.content.trim_space().starts_with('//'){
		content = lin.content.all_after_first('//').trim_space() + '\n'
		prefix = CommentPrefix.short
		singleline = true
	}

	if lin.content.starts_with('<!--') && !lin.content.ends_with('-->'){
		content = lin.content.all_after_first('<!--')
		prefix = CommentPrefix.multi
		singleline = false
	}

	return Comment{
		content: content
		prefix: prefix
		singleline: singleline
	}
}

fn (lin Line)get_header()Header{
	mut depth := 0
	mut content := ""
	if lin.content.starts_with('#'){
		content = lin.content.all_after_first('#').trim_space()
		depth = 1
	}
	if lin.content.starts_with('##'){
		content = lin.content.all_after_first('##').trim_space()
		depth = 2
	}
	if lin.content.starts_with('###'){
		content = lin.content.all_after_first('###').trim_space()
		depth = 3
	}
	if lin.content.starts_with('####'){
		content = lin.content.all_after_first('####').trim_space()
		depth = 4
	}
	if lin.content.starts_with('#####'){
		content = lin.content.all_after_first('#####').trim_space()
		depth = 5
	}

	return Header{
		content: content
		depth: depth
	}
}


















// // walk backwards over the objects, if equal with what we have we keep on walking back
// // if we find one which is same type as specified will return
// fn (mut parser Parser) item_get_previous(tocheck_ string, ignore_ []string) &DocItem {
// 	mut ignore := ignore_.clone()
// 	mut itemnr := doc.items.len - 1
// 	mut itemname_start := doc.items[itemnr].type_name().all_after_last('.').to_lower()
// 	tocheck := tocheck_.to_lower().trim_space()
// 	// walk backwards till previous state is not the current
// 	// the original itemname
// 	// print(" .. previous $tocheck $ignore")
// 	if itemname_start == tocheck {
// 		// print(" *R0.$itemname_start\n")
// 		return &doc.items[itemnr]
// 	}
// 	for {
// 		mut itemname_current := doc.items[itemnr].type_name().all_after_last('.').to_lower()
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
// 			return &doc.items[itemnr]
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
