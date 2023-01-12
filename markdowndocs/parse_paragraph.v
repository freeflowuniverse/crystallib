module markdowndocs


// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// adds the found links, text, comments to the paragraph
fn parse_paragraph(path string) !Paragraph {
	mut para := Paragraph{}
	mut parser := parser_char_new(path)!
	for {		
		if parser.eof() {
			if parser.group.content.len > 0 {
				para.items << text_new(parser.group.content)!
			}
			break
		}
		parser.group_add()

		mut doc := get(path)!
		mut llast := doc.items.last()

		// go out of loop if end of file
		char_ := parser.char_current()	

		// check for comments end
		if mut llast is Comment {
			if char_ == "\n"{
				if llast.singleline{
					//means we are at end of line of a single line comment
					parser.next_start()
					continue
				}else{
					//now we know for sure comment is not single line
					llast.singleline=false
				}
			}
			if parser.text_next_is('-->'){
				//means is end of comment
				parser.next_start()
				continue	
			}
			continue
		}

		if mut llast is Link {
			if char_ == ']' {
				if ! parser.text_next_is("("){
					//means is not link
					para.items.delete_last()
					parser.next_start()
					continue
				}
			}
			if char_ == ')' {
				// end of link
				llast.content=parser.group.content
				parser.group_new() //restart the group
				parser.next_start()
				continue				
			} 
		} 
		
		if parser.atstart {

			// check for comments start
			for totry in ['<!--','//']{
				if parser.text_previous_was(totry) {
					//we are now in comment
					normaltext := parser.group.content.substr(0,parser.group.content.len - totry.len)
					para.items<<text_new(normaltext.str())!//means what is captured till now is text
					para.items<<comment_new()
					if totry == "//"{
						if mut llast is Comment {
							llast.singleline = true
						}
					}					
					parser.group_new()//lets start capturing from now again
					parser.next()
					continue
				}			
			}
			//means we have empty sheet to check what has to come
			if char_ == '[' {
				mut l:= link_new()
				parser.group_new() //restart the group
				charprev := parser.char_prev()
				if charprev == '!' {
					l.cat =	.image
					parser.group.content = '!['
				}else{
					parser.group.content = '['
				}
				para.items << l
				parser.next()
				continue				
			}
		}

	}
	return para
}



