module elements

import freeflowuniverse.crystallib.data.actionparser

pub struct CodeBlock {
	DocBase
pub mut:
	category string
}

pub fn (mut self CodeBlock) process() !int {
	for mut parent in self.parents {
		parent.elements << self
	}
	if self.processed {
		return 0
	}
	mut collection := actionparser.parse_collection(text: self.content)!
	for action in collection.actions {
		self.elements << Action{
			action: action
		}
	}

	// now see if there is something left in codeblock, if yess add that one to the parent_elements
	if collection.othertext.len > 0 {
		text_new(parents: self.parents, content: collection.othertext)
	}

	self.process_elements()!
	self.processed = true
	return 1
}

pub fn (self CodeBlock) markdown() string {
	mut out := ''
	out += '```${self.category}\n'
	out += self.content.trim_space()
	out += '\n```\n'
	return out
}

pub fn (mut self CodeBlock) html() string {
	return self.markdown()
}

[params]
pub struct CodeBlockArgs {
	ElementNewArgs
pub mut:
	category string
}

pub fn codeblock_new(args_ CodeBlockArgs) CodeBlock {
	mut args := args_
	mut a := CodeBlock{
		content: args.content
		type_name: 'codeblock'
		parents: args.parents
		category: args.category
	}
	if args.add2parent {
		for mut parent in a.parents {
			parent.elements << a
		}
	}
	return a
}
