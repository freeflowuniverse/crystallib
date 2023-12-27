module play

import freeflowuniverse.crystallib.osal.gittools

pub fn (mut session Session) play_git() ! {
	for mut action in session.plbook.find(filter: 'gittools.*')! {
		mut p := action.params
		mut repo := p.get_default('repo', '')!
		mut account := p.get_default('account', '')!
		mut provider := p.get_default('provider', '')!
		// mut filter := p.get_default('filter', '')!
		mut url := p.get_default('url', '')!

		mut cmd := action.name

		mut coderoot := ''
		if p.exists('coderoot') {
			coderoot = p.get_path('coderoot')!
		}

		if (repo == '' || account == '' || provider == '') && url == '' {
			return error('need to specify repo, account and provider if url is not specified')
		}

		mut gs := gittools.get(coderoot: coderoot) or {
			return error("Could not find gittools on '${coderoot}'\n${err}")
		}

		gs.do(
			cmd: cmd
			filter: action.params.get_default('filter', '')!
			repo: repo
			account: account
			provider: provider
			script: action.params.get_default_false('script')
			reset: action.params.get_default_false('reset')
			msg: action.params.get_default('message', '')!
			url: url
		)!
		// println(gs)
		action.done = true
	}
}
