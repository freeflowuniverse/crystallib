module elements

fn (mut self Doc) remove_empty_elements() ! {
	mut to_delete := []int{}
	for id, element in self.children {
		// remove the elements which are empty
		if element.content.trim_space() == '' {
			to_delete << id
		}
	}

	self.delete_from_children(to_delete)
}

fn (mut self Doc) delete_from_children(to_delete []int) {
	mut write := 0
	mut delete_ind := 0
	for i := 0; i < self.children.len; i++ {
		if delete_ind < to_delete.len && i == to_delete[delete_ind] {
			delete_ind++
			continue
		}
		self.children[write] = self.children[i]
		write++
	}

	self.children = self.children[0..write]
}

pub fn (mut self Doc) process_elements() !int {
	self.remove_empty_elements()!

	for {
		mut changes := 0
		for id, _ in self.children {
			mut element := self.children[id]
			changes += element.process(mut self)!
		}
		if changes == 0 {
			break
		}
	}
	return 0
}

pub fn (self Doc) markdown() string {
	mut out := ''
	for element in self.children {
		print('element ${element.id} markdown: ${element.markdown()}')
		out += element.markdown()
	}
	return out
}

pub fn (mut self Doc) html() string {
	mut out := ''
	for mut element in self.children {
		out += element.html()
	}
	return out
}

fn (mut self Doc) treeview_(prefix string, mut out []string) {
	out << '${prefix}- ${self.type_name:-30} ${self.content.len}'
	for mut element in self.children {
		element.treeview_(prefix + '  ', mut out)
	}
}
