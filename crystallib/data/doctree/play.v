import data.doctree
import freeflowuniverse.crystallib.core.play

pub fn play(args play.PlayArgs) ! {
	mut session := play.session(args)!
	for action in session.actions.find(filter: ['doctree', 'otheractor:add']) {
		mut p := action.params
		match action.name {
			'playbooks_scan' {
				// playbooks_scan(p)!
				panic('implement')
			}
			else {
				return error('action name ${action.name} not supported')
			}
		}
	}
}

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
