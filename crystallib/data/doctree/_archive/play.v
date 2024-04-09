module doctree

// import freeflowuniverse.crystallib.core.base as playm

// TODO: implement

// pub fn play(args playm.PlayArgs) ! {
// 	mut session := playm.session(args)!
// 	for action in session.actions.find(filter: ['doctree', 'otheractor:add']) {
// 		match action.name {
// 			'collections_scan' {
// 				// collections_scan(p)!
// 				panic('implement')
// 			}
// 			else {
// 				return error('action name ${action.name} not supported')
// 			}
// 		}
// 	}
// }

// // collections_scan scans a path for collections and adds the collections to actor's doctree
// fn (mut actor PublisherActor) collections_scan(action collection.Action) ! {
// 	git_url := action.params.get('git_url')!
// 	git_root := action.params.get('git_root')!
// 	lock actor.doctree {
// 		actor.doctree.scan(
// 			git_url: git_url
// 			git_root: git_root
// 			heal: true
// 		)!
// 	}
// }
