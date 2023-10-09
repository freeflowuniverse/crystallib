module knowledgetree

import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.core.pathlib

// need to become part of baobab.actionexecutor...
// and not everything file,page, ... all doesn't need to be added, that will never happen from a 3script

// pub fn (mut tree Tree) execute(parser actions.Actions) ! {
// 	for action in parser.actions {
// 		tree.logger.debug('Executing action: ${action}')

// 		match action.name {
// 			'books.create' {
// 				book_name := action.params.get('name')!
// 				book_path := action.params.get('path')!
// 				book_dest := action.params.get_default('dest', 'mdbook_${book_name}')!

// 				book_new(
// 					path: book_path
// 					name: book_name
// 					dest: book_dest
// 				)!
// 			}
// 			'collection.add' {
// 				collection_name := action.params.get('name')!
// 				collection_path := action.params.get('path')!
// 				_ := tree.collection_new(name: collection_name, path: collection_path, heal: true)!
// 			}
// 			'page.add' {
// 				collection_name := action.params.get('collection')!
// 				page_path := action.params.get('path')!

// 				mut p := pathlib.get_file(page_path, false)!
// 				if !p.exists() {
// 					return error('cannot find page: ${p}')
// 				}

// 				mut collection := tree.collection_get(collection_name)!
// 				collection.page_new(mut p)!
// 			}
// 			'file.add' {
// 				collection_name := action.params.get('collection')!
// 				page_path := action.params.get('path')!

// 				mut p := pathlib.get_file(page_path, false)!
// 				if !p.exists() {
// 					return error('cannot find page: ${p}')
// 				}

// 				mut collection := tree.collection_get(collection_name)!
// 				collection.file_new(mut p)!
// 			}
// 			'image.add' {
// 				collection_name := action.params.get('collection')!
// 				page_path := action.params.get('path')!

// 				mut p := pathlib.get_file(page_path, false)!
// 				if !p.exists() {
// 					return error('cannot find page: ${p}')
// 				}

// 				mut collection := tree.collection_get(collection_name)!
// 				collection.image_new(mut p)!
// 			}
// 			else {
// 				tree.logger.error('Unknown action ${action}')
// 			}
// 		}
// 	}
// }
