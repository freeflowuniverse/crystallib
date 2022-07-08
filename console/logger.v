module console

import time

pub enum LogLevel {
	error
	warning
	info
	debug
}

pub struct Logger {
pub mut:
	level LogLevel
}

fn (log Logger) output(msg string, t LogLevel) {
	if int(log.level) >= int(t) {
		println(msg)
	}
}

pub fn (log Logger) info(msg string) {
	log.output('$time.now() | ' + 'INFO' + '\t| ' + msg, .info)
}

[if debug]
pub fn (log Logger) debug(msg string) {
	log.output('$time.now() | ' + color_fg('DEBUG', 'blue') + '\t| ' + color_fg(msg, 'light_blue'),
		.debug)
}

pub fn (log Logger) warning(msg string) {
	log.output('$time.now() | ' + color_fg('WARNING', 'yellow') + '\t| ' +
		color_fg(msg, 'light_yellow'), .warning)
}

pub fn (log Logger) success(msg string) {
	println('$time.now() | ' + color_fg('SUCCESS', 'green') + '\t| ' + color_fg(msg, 'light_green'))
}

pub fn (log Logger) error(msg string) {
	eprintln('$time.now() | ' + style(color_fg('ERROR', 'red'), 'bold') + '\t| ' +
		color_fg(msg, 'light_red'))
}

pub fn (log Logger) critical(msg string) {
	eprintln('$time.now() | ' + style(color_bg('CRITICAL', 'red'), 'bold') + '\t| ' +
		style(color_bg(msg, 'light_red'), 'bold'))
}
