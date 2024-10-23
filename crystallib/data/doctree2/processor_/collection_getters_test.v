module processor

import os

const testpath = os.dir(@FILE) + '/testdata'

fn test_collection_get() {
	mut tree := new(name: 'test')!
	tree.scan(
		path: doctree.testpath
		heal: false
	)!

	mut c := tree.collection_get('fruits')!
	assert c.name == 'fruits'
	assert c.pages.keys().len == 3

	c = tree.collection_get('rpc')!
	assert c.name == 'rpc'
	assert c.pages.keys().len == 5
}

fn test_collection_exists() {
	mut tree := new(name: 'test')!
	tree.scan(
		path: doctree.testpath
		heal: false
	)!

	collections := ['btc_examples', 'eth_examples', 'explorer_examples', 'ipfs_examples',
		'metrics_examples', 'nostr_examples', 'sftpgo_examples', 'stellar_examples',
		'tfchain_examples', 'tfgrid_examples', 'fruits', 'rpc', 'server', 'test_vegetables']
	for collection in collections {
		assert tree.collection_exists(collection)
	}

	assert tree.collection_exists('non_existent_collection') == false
}

fn test_page_get() {
	mut tree := new(name: 'test')!
	tree.scan(
		path: doctree.testpath
		heal: false
	)!

	assert tree.collection_exists('non_existent_collection') == false
}
