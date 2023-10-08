module actions

// import os

// THINK we should do this differently

// [params]
// pub struct ReplaceBlock {
// 	new_block Block
// 	action    Action
// 	context   Context
// }

// pub fn (action Action) rewrite_action() ! {
// 	mut content := os.read_file(args.context.source_file) or {
// 		return error('Failed to load file ${args.context.source_file}: ${err}')
// 	}
// 	mut blocks := parse_into_blocks(content, args.context.source_file)!
// 	// blocks.blocks.delete(args.context.block_index, args.new_block)
// 	// blocks.blocks.insert(args.context.block_index, args.new_block)

// 	mut prev_index := 0
// 	for i, block in blocks.blocks {
// 		mut start_index := content.index_after(block.name, prev_index + 1) - 2
// 		for j in 1 .. i + 1 {
// 			start_index = content.index_after('!!${block.name}', start_index + 1)
// 		}

// 		if i < args.context.block_index {
// 			continue
// 		}

// 		end_index := content.index_after('\n\n', start_index + 1)

// 		//! this is flimsy
// 		// TODO: find better solution later

// 		mut new_content := content[..start_index] + '${args.action}'
// 		new_content += content[end_index..]
// 		prev_index = end_index
// 		println('debugzo3: ${new_content}')
// 		os.write_file(args.context.source_file, new_content)!
// 		content = new_content

// 		return
// 	}
// }

// [params]
// pub struct AddIdToActionArgs {
// 	id      string
// 	action  Action
// 	context Context
// }

// pub fn add_id_to_action(args AddIdToActionArgs) ! {
// 	mut split := '${args.action}'.split('\n')
// 	action_name := split[0]
// 	split.insert(1, '\tid: ${args.id}')
// 	content := split[0..].join('\n')
// 	new_block := Block{
// 		name: action_name
// 		content: content
// 	}

// 	replace_block(
// 		action: args.action
// 		context: args.context
// 		new_block: new_block
// 	)!
// }
