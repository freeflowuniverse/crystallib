
module elements

type DocElement = HTML | None | Paragraph | Text | Action

fn (mut self DocBase) process_elements() !int {
	//loop over the process table, only when no changes are further done we stop
	for {
		mut result:=[]DocElement{}
		mut changes:=0
		mut elements := self.elements
		self.elements = []DocElement{}
		for mut element in elements {
			match mut element {

				HTML {
					changes+=element.process()!
				}
				None {
					changes+=element.process()!
				}
				Paragraph {
					changes+=element.process()!
				}
				Text {
					changes+=element.process()!
				}
				Action {
					changes+=element.process()!
				}
				else{
					return error("element $element not supported")
				}
			}
		}
		if changes==0{
			break
		}
		self.elements = result		
	}
	return 0
}

pub fn (mut self DocBase) markdown() string {
	mut out := ''
	for mut element in self.elements {
		match mut element {

			HTML { out += element.markdown() }
			None { out += element.markdown() }
			Paragraph { out += element.markdown() }
			Text { out += element.markdown() }
			Action { out += element.markdown() }
			else{return error("Cannot find element $element")}
		}
	}
	return out
}

pub fn (mut self DocBase) html() string {
	mut out := ''
	for mut element in self.elements {
		match mut element {

			HTML { out += element.html() }
			None { out += element.html() }
			Paragraph { out += element.html() }
			Text { out += element.html() }
			Action { out += element.html() }
			else{return error("Cannot find element $element")}
		}
	}
	return out
}
