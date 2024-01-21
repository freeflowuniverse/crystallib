module doctree

import freeflowuniverse.crystallib.core.play as playm

// TODO: implement

// pub fn play(args playm.PlayArgs) ! {
// 	mut session := playm.session(args)!
// 	for action in session.actions.find(filter: ['doctree', 'otheractor:add']) {
// 		match action.name {
// 			'playbooks_scan' {
// 				// playbooks_scan(p)!
// 				panic('implement')
// 			}
// 			else {
// 				return error('action name ${action.name} not supported')
// 			}
// 		}
// 	}
// }

// // playbooks_scan scans a path for playbooks and adds the playbooks to actor's doctree
// fn (mut actor PublisherActor) playbooks_scan(action playbook.Action) ! {
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
