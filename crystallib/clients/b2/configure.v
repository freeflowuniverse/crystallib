module b2

import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct Config {
pub mut:
	name    string
	keyid   string
	keyname string
	appkey string
}




// return a config object even if from partial info
pub fn config(args Config) Config {
	return args
}

// get the configurator
pub fn configurator(instance string, mut context play.Context) !play.Configurator[Config] {
	mut c := play.configurator_new[Config](
		name: 'b2client'
		instance: instance
		context: context
	)!
	return c
}

// !!b2.define
//     name:'tf_write_1'
//     description:'ThreeFold Read Write Repo 1
//     keyid:'003e2a7be6357fb0000000001'
//     keyname:'tfrw'
//     appkey:'K003UsdrYOZou2ulBHA8p4KLa/dL2n4'
//
pub fn play_session(mut session play.Session) ! {
	for mut action in session.plbook.find(filter: 'b2.define')! {
		mut p := action.params
		mut args := config()
		args.instance = p.get_default('name', '')!
		if args.instance == '' {
			args.instance = p.get_default('instance', 'default')!
		}
		args.description = p.get('description')!
		args.keyid = p.get('keyid')!
		args.keyname = p.get('keyname')!
		args.appkey = p.get('appkey')!
		mut c := configurator(args.instance, session: session)!
		c.set(args)!
	}
}

pub fn configure_interactive(mut args Config, mut session play.Session) ! {
	mut myui := ui.new()!
	console.clear()
	println('\n## Configure B2 Client')
	println('========================\n\n')

	args.instance = myui.ask_question(
		question: 'name for B2 (backblaze) client'
		default: args.instance
	)!

	args.smtp_login = myui.ask_question(
		question: 'description'
		minlen: 0
		default: args.description
	)!
	args.b2_from = myui.ask_question(
		question: 'keyid e.g. 003e2a7be6357fb0000000001'
		minlen: 5
		default: args.keyid
	)!

	args.smtp_addr = myui.ask_question(
		question: 'appkey e.g. K008UsdrYOAou2ulBHA8p4KBe/dL2n4'
		minlen: 5
		default: args.appkey
	)!
	mut c := configurator(args.instance, session: session)!
	c.set(args)!
}
