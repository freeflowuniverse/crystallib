// module main

// // import freeflowuniverse.crystallib.publisher2
// import timurgordon.publisher_ui

// import net.smtp
// import vweb
// import vweb.sse
// import time { Time }
// import rand { ulid }
// import os
// import v.ast
// import crypto.rand as crypto_rand
// import sqlite
// import freeflowuniverse.crystallib.publisher2 { Publisher, User, ACE, ACL, Authentication, Email, Right, Access }
// import freeflowuniverse.crystallib.core.pathlib { Path }

// fn do() ? {
// 	mut publisher := publisher2.get()?
// 	user_timur := publisher.user_add('timur@threefold.io')

// 	// new site zanzibar that is accessible to with email
// 	sitename1 := 'zanzibar'
// 	site1 := publisher.site_add(sitename1, .book)
// 	site_path1 := Path {
// 		path: '/Users/timurgordon/code/github/ourworld-tsc/ourworld_books/docs/zanzibar'
// 	}
// 	publisher.sites["zanzibar"].path = site_path1
// 	publisher.sites["zanzibar"].authentication.email_required = true
// 	publisher.sites["zanzibar"].authentication.email_authenticated = false
// 	if ! os.exists('sites/$sitename1') {
// 		os.symlink(site_path1.path, 'sites/$sitename1')?
// 	}

// 	acl := publisher.acl_add('admins')
// 	mut ace := publisher.ace_add('admins', .write)
// 	publisher.ace_add_user(mut ace, user_timur)
// 	publisher.site_acl_add('admins', acl)

// 	// new site zanzibar feasibility that requires authenticated email
// 	sitename2 := 'ourworld_zanzibar_feasibility'
// 	site2 := publisher.site_add("ourworld_zanzibar_feasibility", .book)
// 	site_path2 := Path {
// 		path: '/Users/timurgordon/code/github/ourworld-tsc/ourworld_books/docs/ourworld_zanzibar_feasibility'
// 	}
// 	publisher.sites["ourworld_zanzibar_feasibility"].path = site_path2
// 	publisher.sites["ourworld_zanzibar_feasibility"].authentication.email_required = true
// 	publisher.sites["ourworld_zanzibar_feasibility"].authentication.email_authenticated = true
// 	if ! os.exists('sites/$sitename2') {
// 		os.symlink(site_path1.path, 'sites/$sitename2')?
// 	}

// 	os.chdir('/Users/timurgordon/code/github/timurgordon/publisher_ui')?
// 	go publisher_ui.run(publisher)
// 	for {}

// }

// fn main() {
// 	do() or { panic(err) }
// }
