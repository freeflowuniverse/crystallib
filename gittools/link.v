module gittools

pub struct GitLinkArgs {
pub:
	gitsource string // the name of the git repo as used in gittools from the source
	gitdest   string // same but for destination
	source    string // if gitsource used, then will be append to the gitsource repo path
	dest      string // if gitdest used, then will be append to the gitfest repo path, to see where link is created
	pull      bool   // means we will pull source & destination
	reset     bool   // means we will reset changes, they will be overwritten
}

// QUESTION: is git link necessary?

// // link a source to a destination, source is where the data is, where we link to
// // the source or dest can be a path or git url, when starting with http or git then we consider it to be a git url
// //
// // struct GitLinkArgs {
// // 	gitsource string   // the name of the git repo as used in gittools from the source
// // 	gitdest string		//same but for destination
// // 	source string		//if gitsource used, then will be append to the gitsource repo path
// // 	dest string			//if gitdest used, then will be append to the gitfest repo path, to see where link is created
// // 	pull bool			//means we will pull source & destination
// // 	reset bool			//means we will reset changes, they will be overwritten
// // }
// //
// // used to process something like:
// // !!git.link
// //     gitsource:owb gitdest:books
// //     source:'feasibility_study/Capabilities'
// //     to:'feasibility_study_internet/src/capabilities2'
// pub fn (mut gs GitStructure) link(args GitLinkArgs) ! {
// 	if args.source.starts_with('http') || args.source.starts_with('get') {
// 		// means its a git repo
// 		mut source_path := ''
// 		if args.gitsource != '' {
// 			// means we need to get gitrepo from gitstructure
// 			mut source_repo := gs.repo_get(gs.locator_new(args.gitsource)!)!
// 			source_path = '${source_repo.path.path}/${args.source}'
// 			if args.reset {
// 				source_repo.remove_changes()!
// 			}
// 			if args.pull {
// 				source_repo.pull()!
// 			}
// 		} else {
// 			mut source_repo := gs.repo_get_from_url(
// 				url: args.source
// 				pull: args.pull
// 				reset: args.reset
// 			)!
// 			source_path = source_repo.path_content_get()
// 		}
// 		mut dest_path := ''
// 		if args.gitdest != '' {
// 			// means we need to get gitrepo from gitstructure
// 			mut dest_repo := gs.repo_get(name: args.gitdest)!
// 			dest_path = '${dest_repo.path.path}/${args.dest}'
// 			if args.reset {
// 				dest_repo.remove_changes()!
// 			}
// 			if args.pull {
// 				dest_repo.pull()!
// 			}
// 		} else {
// 			mut dest_repo := gs.repo_get_from_url(url: args.dest, pull: args.pull, reset: args.reset)!
// 			dest_path = dest_repo.path_content_get()
// 		}

// 		mut source_path_object := pathlib.get(source_path)
// 		mut dest_path_object := pathlib.get(dest_path)
// 		source_path_object.check()
// 		if !source_path_object.exists() {
// 			return error('Cannot link from unexisting source')
// 		}
// 		if source_path_object.is_dir() {
// 			if dest_path_object.exists() {
// 				if dest_path_object.is_dir_link() {
// 					// means is a dir, and a link so can safely be removed
// 					dest_path_object.delete()!
// 				}
// 				if dest_path_object.exists() {
// 					return error('cannot link to a dir:${dest_path}, it exists and is not a link to a dir.')
// 				}
// 			}
// 			source_path_object.link(dest_path_object.path, true)!
// 		}
// 	}
// }
