module actionsparser

import os
import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.texttools

enum ParseBlockStatus {
	start
	action
}

enum ParseStatus {
	start
	actionstart // found !! or #!! or //!!, now we need to find action name
	param_name // need to get params out
	param_value_quote // found ' need to find ending '
	param_value_multiline // busy finding the multiline
	comment // found // or # at end
}

// first step is to get the blocks out
struct Blocks {
mut:
	blocks []Block
}

struct Block {
mut:
	name    string
	content string
}

// path can be a directory or a file
pub fn (mut actions ActionsParser) path_add(path string) ! {
	// recursive behavior for when dir
	// println(" -- add: $path")
	if os.is_dir(path) {
		mut items := os.ls(path)!
		items.sort() // make sure we sort the items before we go in
		// process dirs first, make sure we go deepest possible
		for path0 in items {
			pathtocheck := '${path}/${path0}'
			if os.is_dir(pathtocheck) {
				actions.path_add(pathtocheck)!
			}
		}
		// now process files in order
		for path1 in items {
			pathtocheck := '${path}/${path1}'
			if os.is_file(pathtocheck) {
				actions.path_add(pathtocheck)!
			}
		}
	}

	// make sure we only process markdown files
	if os.is_file(path) {
		if path.to_lower().ends_with('.md') {
			actions.file_parse(path)!
		}
	}
}

fn (mut actions ActionsParser) file_parse(path string) ! {
	if !os.exists(path) {
		return error("path: '${path}' does not exist, cannot parse.")
	}
	content := os.read_file(path) or { return error('Failed to load file ${path}: ${err}') }
	actions.text_add(content)!
}

fn (mut actions ActionsParser) text_add(content string) ! {
	blocks := parse_into_blocks(content)!
	actions.parse_actions(blocks)!
}

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL actions BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT RELIALITIES

// decides if a line might contain parameter definitions
// most ide's auto dedent indented markdown so is necessary
// TODO: figure out way to apply to all possible params
// fn contains_params(line string) bool {
// 	param_keys := ['gitsource', 'gitdest', 'source', 'dest', 'name', 'url', 'path', 'message']
// 	return param_keys.any(line.contains('${it}:'))
// }
// TODO: this is bad way how to do this, editors shouldn't do this, or configure editor differently, you're basically changing the way how the parser works, not ok

// each block is name of action and the full content behind
fn parse_into_blocks(text string) !Blocks {
	mut state := ParseBlockStatus.start
	mut blocks := Blocks{}
	mut block := Block{}
	mut pos := 0
	mut line2 := ''
	mut rid := ''
	mut book := ''
	mut actor := ''

	mut prefix := ''
	// no need to process files which are not at least 2 chars
	for line_ in text.split_into_lines() {
		line2 = line_
		line2 = line2.replace('\t', '    ')
		line2_nospace := line2.trim_space()

		// remove lines with comments
		if line2_nospace.starts_with('<!--') || line2_nospace.starts_with('#')
			|| line2_nospace.starts_with('//') {
			continue
		}
		if state == ParseBlockStatus.action {
			if (line2.starts_with(' ') || line2 == '') && !line2.contains('!!') {
				// starts with tab or space, means block continues
				block.content += '\n'
				block.content += line2
			} else {
				// means block stops
				state = ParseBlockStatus.start
				// add found block
				block.clean()
				blocks.blocks << block
				block = Block{} // new block
			}
		}
		if state == ParseBlockStatus.start {
			if line2.starts_with('!!') || line2.starts_with('#!!') || line2.starts_with('//!!') {
				state = ParseBlockStatus.action
				pos = line2.index(' ') or { 0 }
				if pos > 0 {
					block.name = line2[0..pos]
					block.content = line2[pos..]
				} else {
					block.name = line2.trim_space() // means no arguments
				}
				block.name = block.name.trim_space().trim_left('#/!')
			}
			continue
		}
	}
	if block.name.len > 0 {
		// add last block to it
		block.clean()
		blocks.blocks << block
	}
	// println(blocks.blocks[13].content)
	return blocks
}

fn (mut block Block) clean() {
	block.name = block.name.trim_space().to_lower()
	block.content = texttools.dedent(block.content) // remove leading space
}

fn (mut actions ActionsParser) parse_block(block Block, prefix string) ! {
	params_ := params.parse(block.content) or { return error('Failed to parse block: ${err}') }

	mut action := Action{
		name: '$prefix$block.name'
		params: params_
	}
	actions.unsorted << action
}

fn (mut actions ActionsParser) parse_actions(blocks Blocks) ! {

	mut actor := ''
	mut book := ''

	for block in blocks.blocks {
		mut prefix := ''
		if book != '' {
			prefix += '${book}.'
		}
		if actor != '' {
			prefix += '${actor}.'
		}

		actions.parse_block(block, prefix)!
		action := actions.unsorted.last()

		if action.name.starts_with('actor.select') {
			prefix := 
			actor = action.params.args[0]
		}

		else if action.name.starts_with('book.select') {
			book = action.params.args[0]
		}
	}
}
