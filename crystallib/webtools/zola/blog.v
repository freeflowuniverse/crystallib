module zola

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.playbook
<<<<<<< HEAD
<<<<<<< HEAD
import freeflowuniverse.crystallib.data.ourtime
=======
>>>>>>> e61681d (example fix wip)
=======
import freeflowuniverse.crystallib.data.ourtime
>>>>>>> 2007ff6 (fix sections processing)

// Blog section for Zola site
pub struct Blog {
	Section
mut:
	posts map[string]Post
}

pub struct Post {
pub:
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 2007ff6 (fix sections processing)
	cid         string          @[required]
	title       string
	name        string
	image       ?&doctree.File
	page        ?&doctree.Page
	date        ourtime.OurTime
	biography   string
	description string
	tags        []string
	categories  []string
	authors     []string
	countries   []string
	cities      []string
<<<<<<< HEAD
=======
	cid           string         @[required]
	title          string
	name          string
	image         ?&doctree.File
	page          ?&doctree.Page
	biography     string
	description   string
	tags []string
	categories    []string
	authors   []string
	countries     []string
	cities        []string
>>>>>>> e61681d (example fix wip)
=======
>>>>>>> 2007ff6 (fix sections processing)
}

@[params]
pub struct BlogAddArgs {
	Section
}

// adds a blog section to the zola site
pub fn (mut site ZolaSite) blog_add(args BlogAddArgs) ! {
	blog_section := Section{
		...args.Section
<<<<<<< HEAD
<<<<<<< HEAD
		name: 'blog'
		title: if args.title != '' { args.title } else { 'Blog' }
		sort_by: if args.sort_by != .@none { args.sort_by } else { .date }
		template: if args.template != '' { args.template } else { 'layouts/blog.html' }
		page_template: if args.page_template != '' {
			args.page_template
		} else {
			'partials/postCard.html'
		}
=======
		name: if args.name != '' { args.name } else { 'blog' }
=======
		name: 'blog'
>>>>>>> 2007ff6 (fix sections processing)
		title: if args.title != '' { args.title } else { 'Blog' }
		sort_by: if args.sort_by != .@none { args.sort_by } else { .date }
		template: if args.template != '' { args.template } else { 'layouts/blog.html' }
<<<<<<< HEAD
		page_template: if args.page_template != '' { args.page_template } else { 'partials/postCard.html' }
>>>>>>> e61681d (example fix wip)
=======
		page_template: if args.page_template != '' {
			args.page_template
		} else {
			'partials/postCard.html'
		}
>>>>>>> 2007ff6 (fix sections processing)
		paginate_by: if args.paginate_by != 0 { args.paginate_by } else { 3 }
	}
	site.add_section(blog_section)!
}

pub struct PostAddArgs {
mut:
	name       string
	page       string
	collection string
	file       string
<<<<<<< HEAD
<<<<<<< HEAD
	pointer    string
=======
	pointer string
>>>>>>> e61681d (example fix wip)
=======
	pointer    string
>>>>>>> 2007ff6 (fix sections processing)
	image      string
}

pub fn (mut site ZolaSite) post_add(args_ PostAddArgs) ! {
	args := site.check_post_add_args(args_)!

	if 'blog' !in site.sections {
		site.blog_add()!
	}

<<<<<<< HEAD
<<<<<<< HEAD
	post := site.get_post(args)!
	image := post.image or { return error('Post must have an image') }
	mut post_page := new_page(
		Page: post.page or { return error('post page not attached') }
		title: post.title
		date: post.date.time()
		description: post.description
		taxonomies: {
			'people':     post.authors
			'tags':       post.tags
			'categories': post.categories
		}
		assets: [post.image?.path]
		extra: {
			'imgPath': image.file_name()
=======
	post := site.get_post(args.pointer)!
=======
	post := site.get_post(args)!
	image := post.image or { return error('Post must have an image') }
>>>>>>> 2007ff6 (fix sections processing)
	mut post_page := new_page(
		Page: post.page or { return error('post page not attached') }
		title: post.title
		date: post.date.time()
		description: post.description
		taxonomies: {
<<<<<<< HEAD
			'people':      post.authors
			'tags': post.tags
			'categories':  post.categories
>>>>>>> e61681d (example fix wip)
=======
			'people':     post.authors
			'tags':       post.tags
			'categories': post.categories
		}
		assets: [post.image?.path]
		extra: {
			'imgPath': image.file_name()
>>>>>>> 2007ff6 (fix sections processing)
		}
	)!
	post_page.name = post.name
	site.sections['blog'].page_add(post_page)!
}

fn (site ZolaSite) check_post_add_args(args_ PostAddArgs) !PostAddArgs {
	if args_.pointer == '' && (args_.collection == '' || args_.page == '') {
		return error('Either pointer or post collection and page must be specified in order to add post')
	}
<<<<<<< HEAD
<<<<<<< HEAD

=======
	
>>>>>>> e61681d (example fix wip)
=======

>>>>>>> 2007ff6 (fix sections processing)
	mut args := args_
	if args.collection == '' {
		args.collection = args.pointer.split(':')[0]
	}
<<<<<<< HEAD
<<<<<<< HEAD

=======
	
>>>>>>> e61681d (example fix wip)
=======

>>>>>>> 2007ff6 (fix sections processing)
	// check collection exists
	_ = site.tree.collection_get(args.collection) or {
		return error('Collection ${args.collection} not found.')
	}
<<<<<<< HEAD
<<<<<<< HEAD

=======
	
>>>>>>> e61681d (example fix wip)
=======

>>>>>>> 2007ff6 (fix sections processing)
	if args.pointer == '' {
		args.pointer = '${args.collection}:${args.name}'
	}
	return args
}

<<<<<<< HEAD
<<<<<<< HEAD
fn (site ZolaSite) get_post(args PostAddArgs) !Post {
	mut page := site.tree.page_get('${args.pointer}') or { return err }
=======
fn (site ZolaSite) get_post(pointer string) !Post {
	mut page := site.tree.page_get('${pointer}') or {
		return err
	}
>>>>>>> e61681d (example fix wip)
=======
fn (site ZolaSite) get_post(args PostAddArgs) !Post {
	mut page := site.tree.page_get('${args.pointer}') or { return err }
>>>>>>> 2007ff6 (fix sections processing)

	actions := page.doc()!.actions()

	post_definitions := actions.filter(it.name == 'post_define')
	if post_definitions.len == 0 {
		return error('specified file does not include a post definition.')
	}
	if post_definitions.len > 1 {
		return error('specified file includes multiple post definitions')
	}

	definition := post_definitions[0]
	name := definition.params.get_default('name', '')!
	image_ := definition.params.get_default('image_path', '')!
	mut post := Post{
		name: name
		page: page
<<<<<<< HEAD
<<<<<<< HEAD
		date: definition.params.get_time_default('date', ourtime.now())!
		cid: definition.params.get_default('cid', '')!
		title: definition.params.get_default('title', '')!
=======
		cid: definition.params.get_default('cid', '')!
>>>>>>> e61681d (example fix wip)
=======
		date: definition.params.get_time_default('date', ourtime.now())!
		cid: definition.params.get_default('cid', '')!
		title: definition.params.get_default('title', '')!
>>>>>>> 2007ff6 (fix sections processing)
		description: definition.params.get_default('description', '')!
		tags: definition.params.get_list_default('tags', [])!
		categories: definition.params.get_list_default('categories', [])!
		authors: definition.params.get_list_default('authors', [])!
		biography: definition.params.get_default('bio', '')!
	}

	if post.cid == '' {
		return error('posts cid cant be empty')
	}

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 2007ff6 (fix sections processing)
	// add image and page to article if they exist
	page_ := definition.params.get_default('page_path', '')!
	if page_ != '' {
		post = Post{
			...post
			page: site.tree.page_get(page_) or { return err }
		}
	}

	// // add image and page to post if they exist
	if image_ != '' {
		post = Post{
			...post
			image: site.tree.image_get('${args.collection}:${image_}') or { return err }
		}
	}
<<<<<<< HEAD
=======
	// // // add image and page to post if they exist
	// if image_ != '' {
	// 	post = Post{
	// 		...post
	// 		image: site.tree.image_get('${args.collection}:${image_}') or {
	// 			println(err)
	// 			return err
	// 		}
	// 	}
	// }
>>>>>>> e61681d (example fix wip)
=======
>>>>>>> 2007ff6 (fix sections processing)
	// image_path := if mut img := post.image {
	// 	// img.copy('${post_dir.path}/${img.file_name()}')!
	// 	img.file_name()
	// } else {
	// 	''
	// }
	return post
<<<<<<< HEAD
<<<<<<< HEAD
}
=======
}
>>>>>>> e61681d (example fix wip)
=======
}
>>>>>>> 2007ff6 (fix sections processing)
