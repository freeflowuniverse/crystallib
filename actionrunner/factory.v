module actionrunner

import os
import net.http

// struct ActionRunner{
// pub mut:

// }

// will look for
// export RUNNERDOC=https://gist.github.com/despiegk/linknotspecified
// if the env argument found will get the code and execute
pub fn run_env() ! {
	mut content := ''
	if 'RUNNERDOC' in os.environ() {
		mut link := os.environ()['RUNNERDOC']
		link = link.trim_right('/')
		if link.starts_with('https://gist.github') {
			if !(link.ends_with('raw')) {
				link += '/raw/'
			}
			resp := http.get(link)!
			content = resp.body
		} else {
			resp := http.get(link)!
			content = resp.body
		}
	} else {
		return error('cannot continue, looking for RUNNERDOC in ENV, do something like\nexport RUNNERDOC=https://gist.github.com/despiegk/linknotspecified')
	}
}

// // run from a path
// pub fn run(path string) ! {
// 	if !os.exists(path) {
// 		return error('cannot find path:${path} for actionrunner')
// 	}
// 	mut s := scheduler_new()
// 	mut session := s.session_new(path)!
// 	session.run_from_dir(path)!
// }

// // parse an actionrunner file
// pub fn run_file(name string, path string) ! {
// 	if !os.exists(path) {
// 		return error('cannot find path:${path} for actionrunner')
// 	}
// 	content := os.read_file(path)!
// 	mut s := run_content(name, content)!
// 	println(s)
// }

// // do it all in one go
// // create scheduler, create session, run the content, and return the session at the end
// pub fn run_content(name string, content string) !SchedulerSession {
// 	mut s := scheduler_new()
// 	mut session := s.session_new(name)!
// 	session.run(content)!
// 	return session
// }
