module markdowndocs

import freeflowuniverse.crystallib.texttools
import os



// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// adds the found links, text, comments to the paragraph
fn paragraph_parse(text string) !Paragraph {
	mut para := Paragraph{}
	mut parser := parser_char_new()
	for {		
		if parser.eof() {
			if parser.group.len>0{
				para.items<<text_new(parser.group)
			}
			break
		}
		parser.group_add()

		mut llast := doc.items.last()

		// go out of loop if end of file
		char := parser.char_current()	

		// check for comments end
		if mut llast is Comment {
			if char=="\n"{
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
			if char == ']' {
				if ! parser.text_next_is("("){
					//means is not link
					para.items.delete_last()
					parser.next_start()
					continue
				}
			}
			if char == ')' {
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
					normaltext := parser.group.substr(0,parser.group.len-totry.len)
					para.items<<text_new(normaltext)//means what is captured till now is text
					para.items<<comment_new()
					if totry == "//"{
						para.items.last().singleline = true
					}					
					parser.group_new()//lets start capturing from now again
					parser.next()
					continue
				}			
			}
			//means we have empty sheet to check what has to come
			if ch == '[' {
				mut l:= link_new()
				parser.group_new() //restart the group
				if charprev == '!' {
					l.cat=.image
					parser.group='!['
				}else{
					parser.group='['
				}
				para.items << l
				parser.next()
				continue				
			}
		}

	}
}



