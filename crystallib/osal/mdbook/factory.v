module mdbook

// import freeflowuniverse.crystallib.osal
// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.osal.gittools
// import freeflowuniverse.crystallib.data.ourtime
// import time
import freeflowuniverse.crystallib.installers.web.mdbook as mdbook_installer
import v.embed_file
import os
// import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.play

@[heap]
pub struct MDBooksFactory {
	play.Base
pub mut:
	path_build     string
	path_publish   string
	embedded_files []embed_file.EmbedFileData @[skip; str: skip]
}

@[params]
pub struct MDBooksFactoryArgs {
pub mut:
	buildroot   string
	publishroot   string
	install     bool   = true
	session     ?&play.Session @[skip; str: skip]
}

pub fn new(args_ MDBooksFactoryArgs) !MDBooksFactory {
	mut args:=args_
	if args.install {
		mdbook_installer.install()!
	}

	if args.buildroot==""{
		args.buildroot = '${os.home_dir()}/hero/var/mdbuild'
	}
	if args.publishroot==""{
		args.publishroot = '${os.home_dir()}/hero/www/info'
	}

	args.publishroot=args.publishroot.replace("~",os.home_dir())
	args.buildroot=args.buildroot.replace("~",os.home_dir())

	mut books := MDBooksFactory{
		path_build: args.buildroot
		path_publish: args.publishroot
		session: args.session
	}

	books.load()!
	return books
}

fn (mut books MDBooksFactory) load() ! {
	books.embedded_files << $embed_file('template/css/print.css')
	books.embedded_files << $embed_file('template/css/variables.css')
	books.embedded_files << $embed_file('template/css/general.css')
	books.embedded_files << $embed_file('template/mermaid-init.js')
	books.embedded_files << $embed_file('template/echarts.min.js')
	books.embedded_files << $embed_file('template/mermaid.min.js')
}

// if true {
// 	panic('generate')
// }
// now we have to reset the rev keys, so we remember current status
// for key, mut status in self.gitrepos_status {
// 	osal.done_set('mdbookrev_${key}', status.revnew)!
// 	status.revlast = status.revnew
// }

// pub struct RepoStatus {
// pub mut:
// 	revlast string
// 	revnew  string
// }

// make sure all intial states for the revisions are reset
// fn (mut self MDBooksFactory) reset_state() ! {
// 	for key, mut status in self.gitrepos_status {
// 		osal.done_set('mdbookrev_${key}', '')!
// 		status.revlast = ''
// 	}
// }

// get all content
// pub fn (mut self MDBooksFactory) pull(reset bool) ! {
// 	console.print_header(' pull mdbooks')
// 	print_backtrace()
// 	self.init()!
// 	for key, repo_ in self.gitrepos {
// 		mut repo := repo_
// 		if reset {
// 			repo.pull_reset(reload: true)! // need to overwrite all changes
// 		} else {
// 			repo.pull(reload: true)! // will not overwrite changes
// 		}
// 		revnew := repo.rev()!
// 		lastrev := osal.done_get('mdbookrev_${key}') or { '' }
// 		self.gitrepos_status[key] = RepoStatus{
// 			revnew: revnew
// 			revlast: lastrev
// 		}
// 	}
// }

// @[params]
// pub struct WatchArgs {
// pub mut:
// 	period int = 300 // 5 min default
// 	reset  bool
// }

// pub fn (mut self MDBooksFactory) watch(args WatchArgs) {
// 	mut t := ourtime.now()
// 	mut last := i64(0)
// 	for {
// 		t.now()
// 		console.print_stdout('${t} ${t.unix_time()} period:${args.period}')
// 		if t.unix_time() > last + args.period {
// 			console.print_header(' will try to check the mdbooks')
// 			self.pull(args.reset) or { panic(" - ERROR: couldn't pull the repo's.\n${err}") }
// 			self.generate() or { panic(" - ERROR: couldn't generate the repo's.\n${err}") }
// 			last = t.unix_time()
// 		}
// 		time.sleep(time.second)
// 		if args.period == 0 {
// 			return
// 		}
// 	}
// }
