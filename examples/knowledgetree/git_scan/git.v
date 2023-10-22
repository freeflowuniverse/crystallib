module main

import freeflowuniverse.crystallib.data.knowledgetree
import freeflowuniverse.crystallib.baobab.smartid
// const path0 = '~/code/github/threefoldfoundation/books'

const reset = true

fn do() ! {
	mut tree := knowledgetree.new(
		cid:smartid.cid_get(name:"testknowledgetree")!
	)!

	tree.scan(
		git_root: '~/code6'
		git_url: 'https://github.com/threefoldfoundation/books/tree/main/content'
		load: true
		heal: false
		git_reset: reset		
	)!

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

	println('OK')
}

fn main() {
	do() or { panic(err) }
}

// git reset --hard && git clean -fxd
