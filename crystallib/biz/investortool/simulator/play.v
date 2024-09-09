module investorsimulator

import freeflowuniverse.crystallib.core.playbook {PlayBook}
import freeflowuniverse.crystallib.biz.investortool

pub fn (mut s Simulator) play(mut plbook PlayBook)!{
	for mut action in plbook.find(filter: 'investorsimulator.user_view_add')!{
		/*
			!!!investorsimulator.user_view_add
				view: view1
				oid: abc
		*/
		mut p := action.params
		view := p.get_default('view', 'default')!
		user_oid := p.get('oid')!

		user := if user_oid in s.it.users { s.it.users[user_oid] } else {
			return error('user with oid ${user_oid} is not found')
		}

		mut v := if view in s.user_views { s.user_views[view] } else {
			s.user_views[view] = []
			s.user_views[view]
		}

		v << user
	}

	for mut action in plbook.find(filter: 'investorsimulator.investor_view_add')!{
		mut p := action.params
		view := p.get_default('view', 'default')!
		investor_oid := p.get('oid')!

		investor := if investor_oid in s.it.investors { s.it.investors[investor_oid] } else {
			return error('investor with oid ${investor_oid} is not found')
		}

		mut v := if view in s.investor_views { s.investor_views[view] } else {
			s.investor_views[view] = []
			s.investor_views[view]
		}

		v << user
	}

	
}