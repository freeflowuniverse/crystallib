module main

import freeflowuniverse.crystallib.data.knowledgetree
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.core.pathlib
import log
import os

const orgpath = os.dir(@FILE) + '/../data'

const workpath = '/tmp/booktest'

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

	logger.info('Making sure all pages exist.')
	assert tree.page_exists('smallbook1:decentralized_cloud')
	assert tree.page_exists('smallbook2:decentralized_cloud')
	assert tree.page_exists('grant.md') // should work because there is only 1

	logger.info('Making sure `page_get` fails for two pages with same name.')
	if _ := tree.page_get('decentralized_cloud') {
		assert false
	} else {
		assert true
	} // should fail because there are 2 now

	// todo: test include works see /Users/despiegk1/code/github/freeflowuniverse/crystallib/examples/knowledgetree/data/smallbook2/decentralized_cloud.md

	// todo: generate the mdbook, see it works

	// println(mypage)

	println('OK')
}

fn main() {
	do() or { panic(err) }
}
