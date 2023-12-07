module mdbook

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.mdbook
// import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.data.ourtime
import time
import v.embed_file
import os

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
	reset           bool
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
	reset       bool
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
		reset: args.reset
	}
	return books
}

pub fn (mut tree MDBooks) load() ! {
	tree.embedded_files << get_embedded_files()
}

pub fn (mut self MDBooks) init() ! {
	self.load()!
	for mut book in self.books {
		book.clone()! // first make sure we know the repo's, don't pull
	}
	self.pull()! // now pull all the repo's
	for mut book in self.books {
		book.prepare()! // now make sure we prepare
	}
	self.reset_state()! // now forget the state
}

fn (mut self MDBooks) generate() ! {
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
pub fn (mut self MDBooks) reset_state() ! {
	for key, mut status in self.gitrepos_status {
		osal.done_set('mdbookrev_${key}', '')!
		status.revlast = ''
	}
}

// get all content
pub fn (mut self MDBooks) pull() ! {
	println(' - pull all mdbooks')
	for key, repo_ in self.gitrepos {
		mut repo := repo_
		if self.reset {
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
}

pub fn (mut self MDBooks) watch(args WatchArgs) {
	mut t := ourtime.now()
	mut last := i64(0)
	for {
		t.now()
		println('${t} ${t.unix_time()} period:${args.period}')
		if t.unix_time() > last + args.period {
			println(' - will try to check the mdbooks')
			self.pull() or { panic(" - ERROR: couldn't pull the repo's.\n${err}") }
			self.generate() or { panic(" - ERROR: couldn't generate the repo's.\n${err}") }
			last = t.unix_time()
		}
		time.sleep(time.second)
		if args.period == 0 {
			return
		}
	}
}
