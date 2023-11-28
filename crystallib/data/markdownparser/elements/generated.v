
module elements

type DocElement = Doc | Html | None | Paragraph | Action | Table | Header | Text | Comment | Include | Codeblock | Link

fn (mut self DocBase) process_elements() !int {
	//loop over the process table, only when no changes are further done we stop
	for {
		mut result:=[]DocElement{}
		mut changes:=0
		mut elements := self.elements.clone()
		self.elements = []DocElement{}
		for mut element in elements {
			match mut element {

				Doc {
					changes+=element.process()!
				}
				Html {
					changes+=element.process()!
				}
				None {
					changes+=element.process()!
				}
				Paragraph {
					changes+=element.process()!
				}
				Action {
					changes+=element.process()!
				}
				Table {
					changes+=element.process()!
				}
				Header {
					changes+=element.process()!
				}
				Text {
					changes+=element.process()!
				}
				Comment {
					changes+=element.process()!
				}
				Include {
					changes+=element.process()!
				}
				Codeblock {
					changes+=element.process()!
				}
				Link {
					changes+=element.process()!
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

			Doc { out += element.markdown() }
			Html { out += element.markdown() }
			None { out += element.markdown() }
			Paragraph { out += element.markdown() }
			Action { out += element.markdown() }
			Table { out += element.markdown() }
			Header { out += element.markdown() }
			Text { out += element.markdown() }
			Comment { out += element.markdown() }
			Include { out += element.markdown() }
			Codeblock { out += element.markdown() }
			Link { out += element.markdown() }
		}
	}
	return out
}

pub fn (mut self DocBase) html() string {
	mut out := ''
	for mut element in self.elements {
		match mut element {

			Doc { out += element.html() }
			Html { out += element.html() }
			None { out += element.html() }
			Paragraph { out += element.html() }
			Action { out += element.html() }
			Table { out += element.html() }
			Header { out += element.html() }
			Text { out += element.html() }
			Comment { out += element.html() }
			Include { out += element.html() }
			Codeblock { out += element.html() }
			Link { out += element.html() }
		}
	}
	return out
}
