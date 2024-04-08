module tfrobot

import freeflowuniverse.crystallib.installers.tfgrid.tfrobot as tfrobot_installer
import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console

pub struct TFRobot[T] {
	play.Base[T]
pub mut:
	jobs map[string]Job
}

pub struct Config {
	play.ConfigBase
pub mut:
	configtype string = 'tfrobot' // needs to be defined	
	mnemonics  string
	network    string
}

pub fn get(args play.PlayArgs) !TFRobot[Config] {
	// tfrobot_installer.install()!
	mut robot := TFRobot[Config]{}
	robot.init(args)!
	return robot
}

pub fn heroplay(args play.PLayBookAddArgs) ! {
	// make session for configuring from heroscript
	mut session := play.session_new(session_name: 'config')!
	session.playbook_add(path: args.path, text: args.text, git_url: args.git_url)!
	for mut action in session.plbook.find(filter: 'tfrobot.define')! {
		mut p := action.params
		instance := p.get_default('instance', 'default')!
		mut cl := get(instance: instance)!
		mut cfg := cl.config()!
		cfg.description = p.get('description')!
		cfg.mnemonics = p.get('mnemonics')!
		cfg.network = p.get('network')!
		cl.config_save()!
	}
}

pub fn (mut self TFRobot[Config]) config_interactive() ! {
	mut myui := ui.new()!
	console.clear()
	println('\n## Configure tfrobot')
	println('========================\n\n')

	mut cfg := self.config()!

	self.instance = myui.ask_question(
		question: 'name for tfrobot'
		default: self.instance
	)!
	cfg.mnemonics = myui.ask_question(
		question: 'please enter your mnemonics here'
		minlen: 24
		default: cfg.mnemonics
	)!

	envs := ['main', 'qa', 'test', 'dev']
	cfg.network = myui.ask_dropdown(
		question: 'choose environment'
		items: envs
	)!

	self.config_save()!
}
