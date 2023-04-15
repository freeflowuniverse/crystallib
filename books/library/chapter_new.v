module library
import freeflowuniverse.crystallib.books.chapter

[params]
pub struct ChapterNewArgs {
	name string
	path string
	giturl string //e.g. 'git@github.com:threefoldfoundation/chapters.git' can also be with https... 
	load bool //if set will scan the dir and load all
}


// add a new chapter 
// path is location where to scan
//example url: url := 'git@github.com:threefoldfoundation/chapters.git'
pub fn (mut library Library) chapter_new(args_ ChapterNewArgs) ! &Chapter {

	mut args := args_
	
	//get git if specified
	if args.giturl.len>0{
		mut gr := gs.repo_get_from_url(url: url, pull: false, reset: reset)!
		args.path = gr.path
	}
	
	mut p := pathlib.get_dir(args.path, false)! // makes sure we have the right path to the chapter dir
	if !p.exists() {
		return error('cannot find chapter on path: ${args.path}')
	}
	p.path_normalize()! // make sure its all lower case and name is proper, will rename the directory if needed

	mut name := args.name
	if name == '' {
		name = p.name()
	}
	mut chapter := chapter.Chapter{
		name: texttools.name_fix_no_ext(name)
		path: p
		chapters: &Library
	}
	if args.load{
		chapter.load()!
	}
	return chapter
}
