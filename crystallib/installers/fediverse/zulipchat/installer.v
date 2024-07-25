module zulipchat

// import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
import freeflowuniverse.crystallib.installers.lang.python
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.core.pathlib

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
	version string
	email string
	hostname string
}

pub fn install(args_ InstallArgs) ! {
	mut args:=args_
	if ! (osal.platform() in [.ubuntu,.arch]) {
		return error('only support arch or ubuntu for now')
	}

	if ! osal.done_exists('zulipchat_install') {
		args.reset = true
	}

	if args.reset{

		url:="https://download.zulip.com/server/zulip-server-latest.tar.gz"
		console.print_debug(' download ${url}')
		// _ = osal.download(
		// 	url: url
		// 	minsize_kb: 20000
		// 	reset: args.reset
		// 	expand_file: '/tmp/download/zulip'
		// )!

		//expands in /tmp/download/zulip/zulip-server-8.4

		cmd:='
		cd /tmp/download/zulip/zulip-server-8.4
		./scripts/setup/install --email=${args.email} --hostname=${args.hostname} --no-dist-upgrade --no-init-db
		'
		println(cmd)

		osal.execute_stdout(cmd)!




	}


	//osal.done_set('zulipchat_install', 'OK')!

	//console.print_header('zulipchat installed properly.')
}
