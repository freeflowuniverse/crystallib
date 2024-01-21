// module doctree

// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.data.markdownparser.elements { Include }
// import freeflowuniverse.crystallib.data.markdownparser
// import os

// fn (mut book MDBook) process_includes() ! {
// 	for _, mut page in book.pages {
// 		mut include_tree := []string{}
// 		book.process_page_includes(mut page, mut include_tree) or {
// 			if err is CollectionError {
// 				book.tree.playbooks[page.playbook_name].error(err)
// 			} else {
// 				return err
// 			}
// 		}
// 	}
// }

// fn (mut book MDBook) process_page_includes(mut page Page, mut include_tree []string) ! {
// 	mut doc := page.doc or { return error('no doc yet on page') }
// 	// check for circular imports
// 	if '${page.playbook_name}:${page.name}' in include_tree {
// 		history := include_tree.join(' -> ')
// 		return CollectionError{
// 			path: page.path
// 			msg: 'Found a circular include: ${history}'
// 			cat: .circular_import
// 		}
// 	}
// 	include_tree << '${page.playbook_name}:${page.name}'

// 	// find the files to import
// 	mut pages_to_include := map[int]Page{}
// 	for x in 0 .. doc.children.len {
// 		mut include := doc.children[x]
// 		if mut include is Include {
// 			$if debug {
// 				println('Including page ${include.content} into ${page.path.path}')
// 			}
// 			mut page_to_include := book.tree.page_get(include.content) or {
// 				book.tree.playbooks[page.playbook_name].error(CollectionError{
// 					path: page.path
// 					msg: "include:'${include.content}' not found for page:${page.path.path}"
// 					cat: .page_not_found
// 				})
// 				continue
// 			}
// 			$if debug {
// 				println('Found page in playbook ${page_to_include.playbook_name}')
// 			}
// 			book.process_page_includes(mut page_to_include, mut include_tree)!
// 			pages_to_include[x] = page_to_include
// 		}
// 	}
// 	page.include(pages_to_include)!
// }
