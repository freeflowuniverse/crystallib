module main

import freeflowuniverse.crystallib.data.knowledgetree
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.core.pathlib
import log
import os

const (
	orgpath  = os.dir(@FILE) + '/../data'
	workpath = '/tmp/booktest'
	bookdest = '/tmp/mdbook_export/testknowledgetree'
)

fn do() ! {
	mut logger := log.Logger(&log.Log{
		level: $if debug { .debug } $else { .info }
	})

	mut p := pathlib.get(orgpath)
	p.copy(dest: workpath, delete: true)! // make sure we have the destination in sync with source

	logger.info('Creating knowledgetree.')
	mut tree := knowledgetree.new(
		cid: smartid.cid_get(name: 'testknowledgetree')!
	)!

	logger.info('Scanning path ${workpath}.')
	tree.scan(
		path: workpath
		heal: true
	)!

	logger.info('Testing there are two collections and all pages exist.')
	assert tree.collection_exists('smallbook1')
	assert tree.collection_exists('smallbook2')
	assert tree.page_exists('smallbook1:decentralized_cloud')
	assert tree.page_exists('smallbook2:decentralized_cloud')
	assert tree.page_exists('grant.md') // should work because there is only 1

	logger.info('Testing `page_get` fails for two pages with same name.')
	if _ := tree.page_get('decentralized_cloud') {
		assert false
	} else {
		assert true
	} // should fail because there are 2 now

	mut book := knowledgetree.book_generate(
		name: 'testknowledgetree'
		tree: tree
		path: '${workpath}/summary.md'
	)!

	book.export()!

	logger.info('Testing include works in smallbook2:decentralized_cloud.md')
	including_page := os.read_file('${bookdest}/smallbook2/decentralized_cloud.html')!	
	assert including_page.contains('ThreeFold is a project the seeks true decentralization for traditional IT capacity generation.')

	logger.info('Testing second include produces error in smallbook2:decentralized_cloud.md')
	assert including_page.contains('ThreeFold is a project the seeks true decentralization for traditional IT capacity generation.')

	logger.info('Testing opening exported book. The book should open in a browser.')
	book.read()!

	logger.info('All assertions have passed. The example has worked without errors.')
	logger.info('Please inspect the opened book to see all errors and expected behaviours are in place.')
}

fn main() {
	do() or { panic(err) }
}
