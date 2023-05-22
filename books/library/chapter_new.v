module library

import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

[params]
pub struct ChapterNewArgs {
pub mut:
	name      string
	path      string
	git_url   string
	git_reset bool
	git_root  string
	git_pull  bool
	heal      bool // healing means we fix images, if selected will automatically load, remove stale links
	load      bool
}

// get a new chapter
pub fn (mut book Book) chapter_new(args_ ChapterNewArgs) !&Chapter {
	mut args := args_
	args.name=texttools.name_fix_no_underscore_no_ext(args.name)
	if args.git_url.len > 0 {
		mut gs := gittools.get(root: args.git_root)!
		mut gr := gs.repo_get_from_url(url: args.git_url, pull: args.git_pull, reset: args.git_reset)!
		args.path = gr.path_content_get()
	}
	mut pp := pathlib.get_dir(args.path, false)!
	mut ch := Chapter{
		name: args.name
		path: pp
		heal: args.heal
		book: &book
	}
	if args.load || args.heal {
		ch.scan()!
	}
	if args.heal {
		ch.fix()!
	}

	book.chapters[ch.name]=&ch
	return book.chapters[ch.name]
}
