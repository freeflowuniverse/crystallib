module knowledgetree

import log
import v.embed_file
// import freeflowuniverse.crystallib.baobab.spawner
// import freeflowuniverse.crystallib.baobab.context
import os

const (
	collections_path = os.dir(@FILE) + '/testdata/collections'
	tree_name        = 'tree_test_tree'
	book1_path       = os.dir(@FILE) + '/testdata/book1'
	book1_dest       = os.dir(@FILE) + '/testdata/_book1'
)

fn create_tree() !Tree {
	new(name: knowledgetree.tree_name)!
	rlock knowledgetrees {
		return knowledgetrees[knowledgetree.tree_name]
	}
}

fn test_init() ! {
	tree := create_tree()
	// tree.embedded_files << $embed_file('template/css/print.css')
	// tree.embedded_files << $embed_file('template/css/variables.css')
	// tree.embedded_files << $embed_file('template/css/general.css')
	// tree.embedded_files << $embed_file('template/mermaid-init.js')
	// tree.embedded_files << $embed_file('template/echarts.min.js')
	// tree.embedded_files << $embed_file('template/mermaid.min.js')
}

fn test_fix() ! {
	// if tree.state == .ok {
	// 	return
	// }
	// for _, mut collection in tree.collections {
	// 	collection.fix()!
	// }
}

fn test_page_get() {
	// p := pointer_new(pointerstr)!
	// mut res := []&Page{}
	// for _, collection in tree.collections {
	// 	if p.collection == '' || p.collection == collection.name {
	// 		if collection.page_exists(pointerstr) {
	// 			res << collection.page_get(pointerstr) or { panic('BUG') }
	// 		}
	// 	}
	// }
	// if res.len == 1 {
	// 	return res[0]
	// } else {
	// 	return NoOrTooManyObjFound{
	// 		tree: &tree
	// 		pointer: p
	// 		nr: res.len
	// 	}
	// }
}

fn test_image_get() {
	// p := pointer_new(pointerstr)!
	// // println("collection:'$p.collection' name:'$p.name'")
	// mut res := []&File{}
	// for _, collection in tree.collections {
	// 	// println(collection.name)
	// 	if p.collection == '' || p.collection == collection.name {
	// 		// println("in collection")
	// 		if collection.image_exists(pointerstr) {
	// 			res << collection.image_get(pointerstr) or { panic('BUG') }
	// 		}
	// 	}
	// }
	// if res.len == 1 {
	// 	return res[0]
	// } else {
	// 	return NoOrTooManyObjFound{
	// 		tree: &tree
	// 		pointer: p
	// 		nr: res.len
	// 	}
	// }
}

fn test_file_get() {
	// p := pointer_new(pointerstr)!
	// mut res := []&File{}
	// for _, collection in tree.collections {
	// 	if p.collection == '' || p.collection == collection.name {
	// 		if collection.file_exists(pointerstr) {
	// 			res << collection.file_get(pointerstr) or { panic('BUG') }
	// 		}
	// 	}
	// }
	// if res.len == 1 {
	// 	return res[0]
	// } else {
	// 	return NoOrTooManyObjFound{
	// 		tree: &tree
	// 		pointer: p
	// 		nr: res.len
	// 	}
	// }
}

fn test_page_exists() {
	// _ := tree.page_get(name) or {
	// 	if err is CollectionNotFound || err is CollectionObjNotFound || err is NoOrTooManyObjFound {
	// 		return false
	// 	} else {
	// 		panic(err)
	// 	}
	// }
	// return true
}

fn test_image_exists() {
	// _ := tree.image_get(name) or {
	// 	if err is CollectionNotFound || err is CollectionObjNotFound || err is NoOrTooManyObjFound {
	// 		return false
	// 	} else {
	// 		panic(err)
	// 	}
	// }
	// return true
}

// exists or too many
fn test_file_exists() {
	// _ := tree.file_get(name) or {
	// 	if err is CollectionNotFound || err is CollectionObjNotFound || err is NoOrTooManyObjFound {
	// 		return false
	// 	} else {
	// 		panic(err)
	// 	}
	// }
	// return true
}
