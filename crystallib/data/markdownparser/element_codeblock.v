module markdownparser
import freeflowuniverse.crystallib.data.actionparser

pub struct CodeBlock {
	DocBase
pub mut:
	blocks []actionparser.Block
}

fn (mut o CodeBlock) process(mut items []DocItem) !int {
	if o.processed{
		items << o
		return 0
	}
	for blocks in actionparser.split_blocks(action.content)!{
		//we found actions in the paragraph
		for action_obj in action_objs{
			items << Action{action:action_obj,
		}		
	}
	action.processed = true
	items << action
	return 1
}

fn (o CodeBlock) wiki() string {
	mut out := ''
	out += '```${o.category}\n'
	out += o.content.trim_space()
	out += '\n```\n\n'
	return out
}

fn (o CodeBlock) html() string {
	return o.wiki()
}
