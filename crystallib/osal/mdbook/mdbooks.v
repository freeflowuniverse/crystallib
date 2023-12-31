module mdbook

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.mdbook
// import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.data.ourtime
import time
import v.embed_file
import os
import freeflowuniverse.crystallib.ui.console

@[heap]
pub struct MDBooks {
pub mut:
	books           []&MDBook                   @[skip; str: skip]
	gitrepos        map[string]gittools.GitRepo
	gitrepos_status map[string]RepoStatus
	coderoot        string
	path_build      string
	path_publish    string
	gitstructure    gittools.GitStructure       @[skip; str: skip]
	embedded_files  []embed_file.EmbedFileData  @[skip; str: skip]
}

pub struct RepoStatus {
pub mut:
	revlast string
	revnew  string
}

@[params]
pub struct MDBooksArgs {
pub mut:
	coderoot    string = '${os.home_dir()}/hero/code'
	buildroot   string = '${os.home_dir()}/hero/var/mdbuild'
	publishroot string = '${os.home_dir()}/hero/www/info'
	install     bool   = true
}

pub fn new(args MDBooksArgs) !MDBooks {
	if args.install {
		mdbook.install()!
	}
	mut gs := gittools.get(coderoot: args.coderoot)!
	mut books := MDBooks{
		coderoot: args.coderoot
		path_build: args.buildroot
		path_publish: args.publishroot
		gitstructure: gs
	}
	return books
}

fn (mut tree MDBooks) load() ! {
	tree.embedded_files << $embed_file('template/css/print.css')
	tree.embedded_files << $embed_file('template/css/variables.css')
	tree.embedded_files << $embed_file('template/css/general.css')
	tree.embedded_files << $embed_file('template/mermaid-init.js')
	tree.embedded_files << $embed_file('template/echarts.min.js')
	tree.embedded_files << $embed_file('template/mermaid.min.js')
}

pub fn (mut self MDBooks) get(name string) !&MDBook {
	for book in self.books {
		if book.name == name {
			return book
		}
	}
	return error("can't find book with name ${name}")
}

fn (mut self MDBooks) init() ! {
	self.load()!
	for mut book in self.books {
		if !book.initdone {
			book.clone()! // first make sure we know the repo's, don't pull
		}
	}
	for mut book in self.books {
		if !book.initdone {
			book.prepare()! // now make sure we prepare
			book.initdone = true
		}
	}
	self.reset_state()! // now forget the state
}

@[params]
pub struct GenerateArgs {
pub mut:
	pull bool
	// reset       bool
}

fn (mut self MDBooks) generate(args GenerateArgs) ! {
	// now we generate all books
	for mut book in self.books {
		book.generate()!
	}
	// if true {
	// 	panic('generate')
	// }
	// now we have to reset the rev keys, so we remember current status
	for key, mut status in self.gitrepos_status {
		osal.done_set('mdbookrev_${key}', status.revnew)!
		status.revlast = status.revnew
	}
}

// make sure all intial states for the revisions are reset
fn (mut self MDBooks) reset_state() ! {
	for key, mut status in self.gitrepos_status {
		osal.done_set('mdbookrev_${key}', '')!
		status.revlast = ''
	}
}

// get all content
pub fn (mut self MDBooks) pull(reset bool) ! {
	console.print_header(' pull mdbooks')
	print_backtrace()
	self.init()!
	for key, repo_ in self.gitrepos {
		mut repo := repo_
		if reset {
			repo.pull_reset(reload: true)! // need to overwrite all changes
		} else {
			repo.pull(reload: true)! // will not overwrite changes
		}
		revnew := repo.rev()!
		lastrev := osal.done_get('mdbookrev_${key}') or { '' }
		self.gitrepos_status[key] = RepoStatus{
			revnew: revnew
			revlast: lastrev
		}
	}
}

@[params]
pub struct WatchArgs {
pub mut:
	period int = 300 // 5 min default
	reset  bool
}

pub fn (mut self MDBooks) watch(args WatchArgs) {
	mut t := ourtime.now()
	mut last := i64(0)
	for {
		t.now()
		console.print_stdout('${t} ${t.unix_time()} period:${args.period}')
		if t.unix_time() > last + args.period {
			console.print_header(' will try to check the mdbooks')
			self.pull(args.reset) or { panic(" - ERROR: couldn't pull the repo's.\n${err}") }
			self.generate() or { panic(" - ERROR: couldn't generate the repo's.\n${err}") }
			last = t.unix_time()
		}
		time.sleep(time.second)
		if args.period == 0 {
			return
		}
	}
}
