module elements

@[heap]
// a group contains a list level (a set of list items with the same indentation and ordering status), 
// and children groups.
pub struct ListGroup {
	DocBase
pub mut:
	indentation int
	order_start ?int // the first list item order, if any
}


pub fn (self ListGroup) markdown()! string {
	mut h := ''
	for _ in 0 .. self.indentation*4 {
		h += ' '
	}

	if order_start := self.order_start{
		return self.ordered_group_markdown(h, order_start)!
	}

	mut out := ''
	for child in self.children{
		if child is ListItem{
			out += '${h}- ${child.markdown()}'
			continue
		}

		out += child.markdown()!
	}
	
	return out
}

fn (self ListGroup) ordered_group_markdown(indentation string, order_start int)! string{
	mut out , mut order := '', order_start
	for child in self.children{
		if child is ListItem{
			out += '${indentation}${order}. ${child.markdown()}'
			order++
			continue
		}

		out += child.markdown()!
	}
	
	return out
}

pub fn (self ListGroup) html() string {
	panic('implement')
}