module actionsparser

import os
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.baobab.smartid

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
	name       string // is the first line, before the first params
	content    string // will have all the param values inside
	comments   []string
	src_path   string
	index      int
	actiontype ActionType
	readwrite  bool
	cid        smartid.CID
}

pub enum ActionType {
	unknown
	dal
	sal
	wal
	macro
}

[params]
pub struct ParserAddArgs {
pub mut:
	text      string
	path      string
	readwrite bool
	cid       smartid.CID
}

// path can be a directory or a file
pub fn (mut parser Parser) add(args ParserAddArgs) ! {
	if args.text.len > 0 {
		println(' -- addcontent: ${args.text}')
		blocks := parse_into_blocks(args.text, args.path, args.readwrite, args.cid)!
		println(blocks)
		parser.parse_actions(blocks)!
	} else {
		println(' -- add: ${args.path}')
		if !os.exists(args.path) {
			return error('Cannot find path: ${args.path}')
		}
		base := os.base(args.path)
		if base.starts_with('_') || base.starts_with('.') {
			return
		}
		if os.is_dir(args.path) {
			mut items := os.ls(args.path)!
			for item in items {
				items.sort() // make sure we sort the actions before we go in
				parser.add(path: '${args.path}/${item}', readwrite: args.readwrite, cid: args.cid)!
			}
		} else if os.is_file(args.path) {
			if args.path.to_lower().ends_with('.md') || args.path.to_lower().ends_with('.txt') {
				content := os.read_file(args.path) or {
					return error('Failed to load file ${args.path}: ${err}')
				}
				parser.add(path: args.path, readwrite: args.readwrite, text: content, cid: args.cid)!
			}
		}
	}
}

// each block is name of action and the full content behind
fn parse_into_blocks(text string, path string, readwrite bool, cid smartid.CID) !Blocks {
	mut state := ParseBlockStatus.start
	mut blocks := Blocks{}
	mut block := Block{
		src_path: path
		index: 0
		readwrite: readwrite
		cid: cid
	}
	mut pos := 0
	mut line2 := ''
	mut block_index := 0

	// no need to process files which are not at least 2 chars
	for line_ in text.split_into_lines() {
		line2 = line_
		line2 = line2.replace('\t', '    ')
		line2_nospace := line2.trim_space()

		// remove lines with comments
		if line2_nospace.starts_with('<!--') || line2_nospace.starts_with('#')
			|| line2_nospace.starts_with('//') {
			block.add_comment(line2)
			continue
		}
		if state == ParseBlockStatus.action {
			if (line2.starts_with(' ') || line2 == '') && !line2.contains('!!') {
				// starts with tab or space, means block continues
				block.content += '\n'
				// if line2.contains("//"){
				// 	block.add_comment(line2.all_after_last("//"))
				// 	line2=line2.all_before("//")
				// }
				block.content += line2.trim_space()
			} else {
				// means block stops
				state = ParseBlockStatus.start
				// add found block
				block.clean()
				blocks.blocks << block
				block_index += 1
				block = Block{
					src_path: path
					index: block_index
					readwrite: readwrite
					cid: cid
				} // new block
			}
		}
		if state == ParseBlockStatus.start {
			if line2.starts_with('!') {
				state = ParseBlockStatus.action
				pos = line2.index(' ') or { 0 }
				if pos > 0 {
					block.name = line2[0..pos]
					mut line4 := line2[pos..].trim_space()
					// if line4.contains("//"){
					// 	block.add_comment( line4.all_after_last("//"))
					// 	line4=line4.all_before("//")
					// }					
					block.content = line4
				} else {
					block.name = line2.trim_space() // means no arguments
				}
				block.name = block.name.trim_space().trim_left('!')
				if line2.starts_with('!!!!!') {
					error('there is no action starting with 5 !')
				} else if line2.starts_with('!!!!') {
					block.actiontype = .macro
				} else if line2.starts_with('!!!') {
					block.actiontype = .wal
				} else if line2.starts_with('!!') {
					block.actiontype = .sal
				} else if line2.starts_with('!') {
					block.actiontype = .dal
				} else {
					panic('bug')
				}
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

fn (mut block Block) add_comment(comment_ string) {
	mut comment := comment_
	if comment.starts_with('<!--') {
		comment = comment[4..]
	}
	comment = comment.trim('# ')
	if comment.ends_with('-->') {
		comment = comment[..(comment.len - 3)]
	}
	comment = comment.trim('# ')
	block.comments << comment
}

fn (mut parser Parser) parse_actions(blocks Blocks) ! {
	println(blocks)
	for block in blocks.blocks {
		parser.parse_block(block)!
	}
}

// go over block, fill in default circle or actor if needed
fn (mut parser Parser) parse_block(block Block) ! {
	params_ := paramsparser.parse(block.content) or {
		return error('Failed to parse block: ${err}')
	}
	mut actor := ''

	name := block.name.all_after_last('.').trim_space().to_lower()
	splitted := block.name.split('.')

	println(splitted)

	if true {
		panic('s')
	}

	// if splitted.len == 1 {
	// 	cid = parser.default_cid.circle
	// 	actor = parser.defaultactor
	// } else if splitted.len == 2 {
	// 	cid = parser.default_cid.circle
	// 	actor = block.name.all_before_last('.')
	// } else if splitted.len == 3 {
	// 	cid = parser.default_cid.circle
	// 	actor = splitted[1]
	// } else if splitted.len == 4 {
	// 	cid = parser.default_cid.circle
	// 	actor = splitted[2]
	// } else {
	// 	cid = 1
	// 	actor = ''
	// 	return error('max 2 . in block.\n${block}')
	// }

	// !!select_cid core
	// !!select_circle aaa
	// !!select_actor people
	// if name == 'select_cid' {
	// 	parser.default_cid.circle = params_.get_arg(0, 1)! // means there needs to be 1 arg
	// 	return
	// }
	// if name == 'select_circle' {
	// 	parser.defaultcircle = params_.get_arg(0, 1)! // means there needs to be 1 arg
	// 	return
	// }
	// if name == 'select_actor' {
	// 	parser.defaultactor = params_.get_arg(0, 1)! // means there needs to be 1 arg
	// 	return
	// }

	$if debug {
		eprintln('${cid} - ${actor} - ${name}')
	}

	cid_check(cid.str(), block.content)!
	if name != 'include' {
		actor_check(actor, block.content)!
	}

	name_check(name, block.content)!

	prio := params_.get_int_default('prio', 5)!
	if prio > 10 {
		return error('priority cannot be higher than 10. \n${block}')
	}

	parser.actions << Action{
		name: name
		cid: cid
		actor: actor
		params: params_
		priority: u8(prio)
		sourcelink: SourceLink{
			path: block.src_path
			block_index: block.index
		}
	}
}
