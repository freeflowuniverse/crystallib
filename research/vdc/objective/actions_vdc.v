module vdc

import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.core.pathlib

// TODO: needs to be done for VDC

pub fn (mut vdc VDC) execute(parser actions.Actions) ! {
	for action in parser.actions {
		vdc.logger.debug('Executing action: ${action}')

		match action.name {
			'books.add' {
				book_name := action.params.get('name')!
				book_path := action.params.get('path')!
				book_dest := action.params.get_default('dest', 'mdbook_${book_name}')!

				vdc.book_new(path: book_path, name: book_name, dest: book_dest)!
			}
			'books.export' {
				vdc.scan()!

				book_name := action.params.get('name')!
				mut book := vdc.book_get(book_name)!
				book.export()!
			}
			'collection.add' {
				collection_name := action.params.get('name')!
				collection_path := action.params.get('path')!
				_ := vdc.collection_new(name: collection_name, path: collection_path, heal: true)!
			}
			'page.add' {
				collection_name := action.params.get('collection')!
				page_path := action.params.get('path')!

				mut p := pathlib.get_file(page_path, false)!
				if !p.exists() {
					return error('cannot find page: ${p}')
				}

				mut collection := vdc.collection_get(collection_name)!
				collection.page_new(mut p)!
			}
			'file.add' {
				collection_name := action.params.get('collection')!
				page_path := action.params.get('path')!

				mut p := pathlib.get_file(page_path, false)!
				if !p.exists() {
					return error('cannot find page: ${p}')
				}

				mut collection := vdc.collection_get(collection_name)!
				collection.file_new(mut p)!
			}
			'image.add' {
				collection_name := action.params.get('collection')!
				page_path := action.params.get('path')!

				mut p := pathlib.get_file(page_path, false)!
				if !p.exists() {
					return error('cannot find page: ${p}')
				}

				mut collection := vdc.collection_get(collection_name)!
				collection.image_new(mut p)!
			}
			else {
				vdc.logger.error('Unknown action ${action}')
			}
		}
	}
}
