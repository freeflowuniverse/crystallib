module doctree

// import freeflowuniverse.crystallib.core.playbook
// import freeflowuniverse.crystallib.core.pathlib

// need to become part of baobab.actionexecutor...
// and not everything file,page, ... all doesn't need to be added, that will never happen from a 3script

// pub fn (mut tree Tree) execute(parser playbook.Actions) ! {
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
// 			'playbook.add' {
// 				playbook_name := action.params.get('name')!
// 				playbook_path := action.params.get('path')!
// 				_ := tree.playbook_new(name: playbook_name, path: playbook_path, heal: true)!
// 			}
// 			'page.add' {
// 				playbook_name := action.params.get('playbook')!
// 				page_path := action.params.get('path')!

// 				mut p := pathlib.get_file(path:page_path)!
// 				if !p.exists() {
// 					return error('cannot find page: ${p}')
// 				}

// 				mut playbook := tree.playbook_get(playbook_name)!
// 				playbook.page_new(mut p)!
// 			}
// 			'file.add' {
// 				playbook_name := action.params.get('playbook')!
// 				page_path := action.params.get('path')!

// 				mut p := pathlib.get_file(path:page_path)!
// 				if !p.exists() {
// 					return error('cannot find page: ${p}')
// 				}

// 				mut playbook := tree.playbook_get(playbook_name)!
// 				playbook.file_new(mut p)!
// 			}
// 			'image.add' {
// 				playbook_name := action.params.get('playbook')!
// 				page_path := action.params.get('path')!

// 				mut p := pathlib.get_file(path:page_path)!
// 				if !p.exists() {
// 					return error('cannot find page: ${p}')
// 				}

// 				mut playbook := tree.playbook_get(playbook_name)!
// 				playbook.image_new(mut p)!
// 			}
// 			else {
// 				tree.logger.error('Unknown action ${action}')
// 			}
// 		}
// 	}
// }
