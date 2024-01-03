module playcmds

import freeflowuniverse.crystallib.osal.zola
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.play

pub fn play_website(mut session play.Session) ! {
	mut coderoot := ''
	mut buildroot := ''
	mut publishroot := ''
	mut install := true
	mut reset := false

	mut config_actions := session.plbook.find(filter: 'websites:configure')!

	if config_actions.len > 1 {
		return error('can only have 1 config action for websites')
	} else if config_actions.len == 1 {
		mut p := config_actions[0].params
		coderoot = p.get_default('coderoot','')!
		buildroot = p.get_default('buildroot','')!
		publishroot = p.get_default('publishroot','')!
		install = p.get_default_true('install')
		reset = p.get_default_false('reset')
		config_actions[0].done = true
	}

	if coderoot == '' {
		coderoot = session.context.coderoot()
	}

	mut websites := zola.new(
		coderoot: coderoot
		buildroot: buildroot
		publishroot: publishroot
		install: install
		reset: reset
	)!


for mut action in session.plbook.find(filter: 'website:define')! {
		mut p := action.params
		name := p.get('name')!
		panic("implement")
		// mut wsite := websites.get(website)!
		// wsite.collection_add(name: name, url: url)!
		action.done = true
	}


	for mut action in session.plbook.find(filter: 'website:add')! {
		mut p := action.params
		name := p.get('name')!
		website := p.get('website')!
		url := p.get('url')!
		panic("implement")
		// mut wsite := websites.get(website)!
		// wsite.collection_add(name: name, url: url)!
		action.done = true
	}

	mut init_done := false
	for mut action in session.plbook.find_max_one(filter: 'websites:pull')! {
		websites.pull()!
		action.done = true
		init_done = true
	}

	for mut action in session.plbook.find(filter: 'websites:generate')! {
		mut p := action.params
		mut pull2 := p.get_default_false('pull')
		if pull2 {
			websites.pull()!
		}
		mut name := p.get_default('name', '')!
		panic("implement")
		// if name.contains(',') {
		// 	names := texttools.toarray(name)
		// 	for name2 in names {
		// 		mut wsite := website.new_from_config(
		// 			websites: &websites
		// 			instance: name2
		// 			reset: reset
		// 			context: &session.context
		// 		)!
		// 		wsite.generate()!
		// 	}
		// } else if name == '' {
		// 	for mut wsite in websites.websites {
		// 		wsite.generate()!
		// 		website.save_to_config(*wsite, mut session.context) !
		// 	}
		// } else {
		// 	mut wsite := website.new_from_config(
		// 		websites: &websites
		// 		instance: name
		// 		reset: reset
		// 		context: &session.context
		// 	)!
		// 	wsite.generate()!
		// 	website.save_to_config(*wsite, mut session.context) !
		// }
		action.done = true
	}

	// for mut action in session.plbook.find(filter:'website:edit')! {
	// 	mut p := action.params
	// 	mut name := p.get('name')!
	// 	mut wsite := websites.get(name)!
	// 	wsite.edit()!
	// 	action.done=true
	// }

	// for mut action in session.plbook.find(filter:'website:open')! {
	// 	mut p := action.params
	// 	mut name := p.get('name')!
	// 	mut wsite := websites.get(name)!
	// 	wsite.open()!
	// 	action.done=true
	// }
}
