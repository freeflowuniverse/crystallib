module console

import time

pub fn info(msg string) {
	println('${time.now()} | ' + 'INFO' + '\t| '+ msg)
}

pub fn debug(msg string) {
	println('${time.now()} | ' + color_fg('DEBUG', 'blue') + '\t| ' + color_fg(msg, 'light_blue'))
}

pub fn success(msg string) {
	println('${time.now()} | ' + color_fg('SUCCESS', 'green') + '\t| ' + color_fg(msg, 'light_green'))
}

pub fn warning(msg string) {
	println('${time.now()} | ' + color_fg('WARNING', 'yellow') + '\t| ' + color_fg(msg, 'light_yellow'))
}

pub fn error(msg string) {
	eprintln('${time.now()} | ' + style(color_fg('ERROR', 'red'), 'bold') + '\t| ' + color_fg(msg, 'light_red'))
}

pub fn critical(msg string) {
	eprintln('${time.now()} | ' + style(color_bg('CRITICAL', 'red'),'bold') + '\t| ' + style(color_bg(msg, 'light_red'),'bold'))
}
