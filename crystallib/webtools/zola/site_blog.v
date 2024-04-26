module zola

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.develop.gittools
// import freeflowuniverse.crystallib.data.markdownparser
// import freeflowuniverse.crystallib.data.markdownparser.elements
import os
import freeflowuniverse.crystallib.core.texttools

@[params]
pub struct BlogAddArgs {
	Section
}

// adds a blog section to the zola site
pub fn (mut site ZolaSite) blog_add(args BlogAddArgs) ! {
	blog_section := Section{
		...args.Section
		name: 'blog'
		title: if args.title != '' { args.title } else { 'Blog' }
		sort_by: if args.sort_by != .@none { args.sort_by } else { .date }
		template: if args.template != '' { args.template } else { 'layouts/blog.html' }
		page_template: if args.page_template != '' {
			args.page_template
		} else {
			'partials/postCard.html'
		}
		paginate_by: if args.paginate_by != 0 { args.paginate_by } else { 3 }
	}
	site.add_section(blog_section)!
}

// TIMUR: PLEASE CHECK

// pub struct BlogAddArgs {
// 	name       string
// 	collection string @[required]
// 	file       string @[required]
// 	image      string
// }

// pub fn (mut site ZolaSite) blog_add(args BlogAddArgs) ! {
// 	site.tree.process_includes()!
// 	_ = site.tree.collection_get(args.collection) or {
// 		println(err)
// 		return err
// 	}
// 	mut page := site.tree.page_get('${args.collection}:${args.file}') or {
// 		println(err)
// 		return err
// 	}
// 	mut image := site.tree.image_get('${args.collection}:${args.image}') or {
// 		println(err)
// 		return err
// 	}

// 	mut blog_index := pathlib.get_file(
// 		path: '${site.path_build.path}/content/blog/_index.md'
// 	)!
// 	if !blog_index.exists() {
// 		blog_index.write('---
// title: "Blog"
// paginate_by: 9

// # paginate_reversed: false

// sort_by: "date"
// insert_anchor_links: "left"
// #base_url: "posts"
// #first: "first"
// #last: "last"
// template: "layouts/blog.html"
// page_template: "blogPage.html"
// #transparent: true
// generate_feed: true
// extra:
//   imgPath: images/threefold_img2.png
// ---
// ')!
// 	}

// 	blog_dir := pathlib.get_dir(
// 		path: '${site.path_build.path}/content/blog'
// 		create: true
// 	)!
// 	fixed_name := '${texttools.name_fix(args.name)}'
// 	post_dir := pathlib.get_dir(
// 		path: '${blog_dir.path}/${fixed_name}'
// 		create: true
// 	)!
// 	page.export(dest: '${post_dir.path}/index.md')!
// 	image.copy('${post_dir.path}/${image.file_name()}')!

// 	site.blog.posts[args.name] = page.doc()!
// }
