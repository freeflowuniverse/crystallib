module markdowndocs


// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// adds the found links, text, comments to the paragraph
fn (mut para Paragraph) parse()! {
	mut parser := parser_char_new_text(para.content)

	para.items << Text{}

	for {		
		if parser.eof() {
			break
		}

		mut llast := para.items.last()
		char_ := parser.char_current()	
		char_debug := char_.replace("\n","\\n")
		println("")
		match llast {
			Link{
				print(" ---- L : $char_debug ")
			}
			Text{
				print(" ---- T : $char_debug ")
			}
			Comment{
				print(" ---- C : $char_debug ")
			}
		}

		// check for comments end
		if mut llast is Comment {
			if char_ == "\n"{
				if llast.singleline{
					//means we are at end of line of a single line comment
					para.items << Text{}
					parser.next()
					continue
				}else{
					//now we know for sure comment is not single line
					llast.singleline=false
				}
			}
			if parser.text_next_is('-->'){
				//means is end of comment
				llast.content+=char_ //need to add current content
				para.items << Text{}
				parser.next()
				continue	
			}
		}

		if mut llast is Link {
			if char_ == ']' {
				if ! parser.text_next_is("("){
					//means is not link, need to convert link to normal text
					mut c:=llast.content
					para.items.delete_last() //remove the link
					para.items << Text{content:c} //we need to re-add the content
					llast = para.items.last() //fetch last again
					llast.content+=char_ //need to add current content
					para.items << Text{}
					parser.next()
					continue
				}
			}
			if char_ == ')' {
				// end of link
				llast.content+=char_ //need to add current content
				para.items << Text{}
				parser.next()
				continue				
			} 
		} 
		
		// check for comments start
		for totry in ['<!--','//']{
			if parser.text_last_is(totry) {
				//we are now in comment
				para.items<<comment_new("")
				llast = para.items.last()
				if totry == "//"{
					if mut llast is Comment {
						llast.singleline = true
					}
				}					
				parser.next()
				continue
			}			
		}
		//could be link
		if char_ == '[' {
			mut l:= link_new()				
			if parser.char_prev() == '!' {
				l.cat =	.image
				l.content = '!['
			}else{
				l.content = '['
			}
			para.items << l
			parser.next()
			continue				
		}

		llast.content+=char_

		// match llast {
		// 	Link{

		// 	}
		// 	Text{

		// 	}
		// 	Comment{

		// 	}

		parser.next()

	}

	mut toremovelist:=[]int{}
	mut counter:=0
	for item in para.items{
		if item is Text{
			if item.content=="" {
				toremovelist << counter
			}
		}
		counter+=1
	}
	for toremove in toremovelist.reverse(){
		para.items.delete(toremove)
	}


}



