module postgres

import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct Config {
pub mut:
	instance     string = 'default'
	user     string = 'root'
	port     int    = 5432
	host     string = 'localhost'
	password string
	dbname   string = 'postgres'
	script3  string
	reset    bool
}

// return a config object even if from partial info
pub fn config(args Config) Config {
	return args
}

// get the configurator
pub fn configurator(instance string, playargs play.PlayArgs) !play.Configurator[Config] {
	mut c := play.configurator_new[Config](
		name: 'postgresclient'
		instance: instance
		playargs: playargs
	)!
	return c
}

pub fn play_session(mut session play.Session) ! {
	for mut action in session.plbook.find(filter: 'postgresclient.define')! {
		mut p := action.params
		mut args := config()
		panic('implement')
		// args.instance = p.get_default('name','')!
		// if args.instance == ""{
		// 	args.instance = p.get_default('instance', 'default')!
		// }				
		// args.mail_from = p.get('mail_from')!
		// args.smtp_addr = p.get('smtp_addr')!
		// args.smtp_login = p.get('smtp_login')!
		// args.smtp_passwd = p.get('smtp_passwd')!
		// args.smpt_port = p.get_int('smpt_port')!		
		// mut c:=configurator(args.instance,session:session)!
		// c.set(args)!
	}
}

pub fn configure_interactive(mut args Config, mut session play.Session) ! {
	mut myui := ui.new()!

	console.clear()
	println('\n## Configure Postgres Client')
	println('============================\n\n')

	args.instance = myui.ask_question(
		question: 'name for postgres client'
		default: args.instance
	)!

	args.user = myui.ask_question(
		question: 'user'
		minlen: 3
		default: args.user
	)!

	args.password = myui.ask_question(
		question: 'password'
		minlen: 3
		default: args.password
	)!

	args.dbname = myui.ask_question(
		question: 'dbname'
		minlen: 3
		default: args.dbname
	)!

	args.host = myui.ask_question(
		question: 'host'
		minlen: 3
		default: args.host
	)!
	mut port := myui.ask_question(
		question: 'port'
		default: '${args.port}'
	)!
	args.port = port.int()

	mut c := configurator(args.instance, session: session)!
	c.set(args)!
}
