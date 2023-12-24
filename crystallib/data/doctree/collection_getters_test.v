module doctree

import os

const testpath = os.dir(@FILE) + '/testdata/playbooks'

fn test_playbook_get() {
	mut tree := tree_create(cid: 'abc', name: 'test')!
	tree.scan(
		path: doctree.testpath
		heal: false
	)!

	mut c := tree.playbook_get('fruits')!
	assert c.name == 'fruits'
	assert c.pages.keys().len == 4

	c = tree.playbook_get('rpc')!
	assert c.name == 'rpc'
	assert c.pages.keys().len == 5
}

fn test_playbook_exists() {
	mut tree := tree_create(cid: 'abc', name: 'test')!
	tree.scan(
		path: doctree.testpath
		heal: false
	)!

	playbooks := ['btc_examples', 'eth_examples', 'explorer_examples', 'ipfs_examples',
		'metrics_examples', 'nostr_examples', 'sftpgo_examples', 'stellar_examples',
		'tfchain_examples', 'tfgrid_examples', 'fruits', 'playground', 'rpc', 'server',
		'test_vegetables']
	for playbook in playbooks {
		assert tree.playbook_exists(playbook)
	}

	assert tree.playbook_exists('non_existent_playbook') == false
}
