module gittools

// QUESTION: is this still necessary

// import freeflowuniverse.crystallib.texttools

// pub fn (mut gitstructure GitStructure) pushcommit(args ReposGetArgs) ! {
// 	texttools.print_clear()
// 	println(" #### push pull commit repo's:")
// 	println('')
// 	gitstructure.repos_print(args)
// 	println('')

// 	if args.message == '' {
// 		return error('Cannot commit, there needs to be a message.')
// 	}

// 	for mut g in gitstructure.repos_get(args) {
// 		if args.pull {
// 			println(' - COMMIT, PULL, PUSH: ${g.addr.name}')
// 		} else {
// 			println(' - COMMIT, PUSH: ${g.addr.name}')
// 		}
// 		changes := g.changes()!
// 		if changes {
// 			g.commit(args.message)!
// 		}
// 		if args.pull {
// 			g.pull()!
// 			g.commit(args.message)!
// 		}
// 		if changes {
// 			g.push()!
// 		}
// 	}
// }

// pub fn (mut gitstructure GitStructure) commit(args ReposGetArgs) ! {
// 	texttools.print_clear()
// 	println(" #### commit repo's:")
// 	println('')
// 	gitstructure.repos_print(args)
// 	println('')

// 	if args.message == '' {
// 		return error('Cannot commit, there needs to be a message.')
// 	}

// 	for mut g in gitstructure.repos_get(args) {
// 		if args.pull {
// 			println(' - COMMIT, PULL: ${g.name()}')
// 		} else {
// 			println(' - COMMIT: ${g.name()}')
// 		}
// 		changes := g.changes()!
// 		if changes {
// 			g.commit(args.message)!
// 		}
// 		if args.pull {
// 			g.pull()!
// 			g.commit(args.message)!
// 		}
// 	}
// }

// pub fn (mut gitstructure GitStructure) push(args ReposGetArgs) ! {
// 	texttools.print_clear()
// 	println(" #### push repo's:")
// 	println('')
// 	gitstructure.repos_print(args)
// 	println('')

// 	for mut g in gitstructure.repos_get(args) {
// 		println(' - push: ${g.name()}')
// 		changes := g.changes()!
// 		if changes {
// 			g.push()!
// 		}
// 	}
// }

// pub fn (mut gitstructure GitStructure) pull(args ReposGetArgs) ! {
// 	texttools.print_clear()
// 	println(" #### pull repo's:")
// 	println('')
// 	gitstructure.repos_print(args)
// 	println('')

// 	for mut g in gitstructure.repos_get(args) {
// 		println(' - push: ${g.name()}')
// 		g.pull()!
// 	}
// }
