module actionsparser

import os

// write back to original
pub fn (action Action) write_source() ! {
	path := action.sourcelink.path

	mut content := os.read_file(path) or { return error('Failed to load file ${path}: ${err}') }
	mut blocks := parse_into_blocks(content, path, true, action.cid)!

	println(blocks)
	if true {
		panic('writeback')
	}

	// mut prev_index := 0
	// for i, block in blocks.blocks {

	// 	mut new_content := content[..start_index] + '${args.action}'
	// 	new_content += content[end_index..]
	// 	prev_index = end_index
	// 	println('debugzo3: ${new_content}')
	// 	content = new_content

	// 	return
	// }

	// os.write_file(path, new_content)!
}
