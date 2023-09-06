module gittools

import freeflowuniverse.crystallib.texttools

pub fn (mut gitstructure GitStructure) pushcommit(args GSArgs) ! {
	texttools.print_clear()
	println(" #### push pull commit repo's:")
	println('')
	gitstructure.repos_print(args)
	println('')

	if args.message == '' {
		return error('Cannot commit, there needs to be a message.')
	}

	for mut g in gitstructure.repos_get(args) {
		if args.pull {
			println(' - COMMIT, PULL, PUSH: ${g.name()}')
		} else {
			println(' - COMMIT, PUSH: ${g.name()}')
		}
		changes := g.changes()!
		if changes {
			g.commit(args.message)!
		}
		if args.pull {
			g.pull()!
			g.commit(args.message)!
		}
		if changes {
			g.push()!
		}
	}
}

pub fn (mut gitstructure GitStructure) commit(args GSArgs) ! {
	texttools.print_clear()
	println(" #### commit repo's:")
	println('')
	gitstructure.repos_print(args)
	println('')

	if args.message == '' {
		return error('Cannot commit, there needs to be a message.')
	}

	for mut g in gitstructure.repos_get(args) {
		if args.pull {
			println(' - COMMIT, PULL: ${g.name()}')
		} else {
			println(' - COMMIT: ${g.name()}')
		}
		changes := g.changes()!
		if changes {
			g.commit(args.message)!
		}
		if args.pull {
			g.pull()!
			g.commit(args.message)!
		}
	}
}

pub fn (mut gitstructure GitStructure) push(args GSArgs) ! {
	texttools.print_clear()
	println(" #### push repo's:")
	println('')
	gitstructure.repos_print(args)
	println('')

	for mut g in gitstructure.repos_get(args) {
		println(' - push: ${g.name()}')
		changes := g.changes()!
		if changes {
			g.push()!
		}
	}
}

pub fn (mut gitstructure GitStructure) pull(args GSArgs) ! {
	texttools.print_clear()
	println(" #### pull repo's:")
	println('')
	gitstructure.repos_print(args)
	println('')

	for mut g in gitstructure.repos_get(args) {
		println(' - push: ${g.name()}')
		g.pull()!
	}
}
