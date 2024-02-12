module zola

// fn (mut self Zola) generate() ! {
// 	// now we generate all sites
// 	for mut site in self.sites {
// 		site.generate(self.gitrepos_status)!
// 	}
// 	// now we have to reset the rev keys, so we remember current status
// 	for key, mut status in self.gitrepos_status {
// 		osal.done_set('zolarev_${key}', status.revnew)!
// 		status.revlast = status.revnew
// 	}
// }

// tailwind: tailwind.new(
// 	name: args.name
// 	path_build: args.path_build
// 	content_paths: ['${args.path_build}/templates/**/*.html',
// 		'${args.path_build}/content/**/*.md']
// )!
