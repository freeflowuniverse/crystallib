module main

import freeflowuniverse.crystallib.knowledgetree

// const path0 = '~/code/github/threefoldfoundation/books'

const reset = true

fn do() ! {
	mut tree := knowledgetree.new()!

	// start a tree
	// now add collections to the tree

	tree.scan(
		git_root: '~/code5'
		git_url: 'https://github.com/threefoldfoundation/books2/tree/main/content'
		git_reset: reset
		load: true
		heal: false
	)!

	println(tree.collections.len)

	p1 := tree.page_get('funny_Comparison')!
	p2 := tree.page_get('funny Comparison.md')!
	assert p1 == p2

	assert p2.pathrel == 'intro/funny_comparison.md'

	println(p1)

	assert tree.page_exists('funny_Comparison')
	assert tree.image_exists('experience_')
	assert tree.image_exists('experience_.png')
	assert tree.image_exists('experience.png')
	assert tree.image_exists('mytwin:experience.png')
	assert tree.image_exists('testbook:mytwin:experience.png')
	assert tree.image_exists('testbook::experience.png')
	assert tree.image_exists('mytwins:experience.png') == false

	assert tree.image_exists('testbook:mytwin:experience.png')
	assert tree.image_exists('testbook::experience.png')
	assert tree.image_exists('testbook::experiencee.png') == false

	mut book := tree.book_new(
		name: 'MyBook'
		path: '~/code5/github/threefoldfoundation/books2/books/threefold_projects_overview'
		dest: '_book1'
	)!
	book.export()!

	println('OK')
}

fn main() {
	do() or { panic(err) }
}

// git reset --hard && git clean -fxd
