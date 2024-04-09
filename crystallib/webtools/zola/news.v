module zola

// import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.data.ourtime
// import freeflowuniverse.crystallib.core.texttools

// News section for Zola site
pub struct News {
	sort_by SortBy = .date
mut:
	articles map[string]Article
}

@[params]
pub struct NewsAddArgs {
	Section
}

pub struct Article {
pub:
	cid         string          @[required]
	title       string
	page_path   string
	name        string
	image       ?&doctree.File
	tags        []string
	authors     []string
	categories  []string
	date        ourtime.OurTime
	page        ?&doctree.Page
	biography   string
	description string
}

// adds a news section to the zola site
fn (mut site ZolaSite) news_add(args NewsAddArgs) ! {
	if 'newsroom' in site.sections {
		return error('News section already exists in zola site')
	}
<<<<<<< HEAD

	news_section := Section{
		...args.Section
		name: 'newsroom'
		title: if args.title != '' { args.title } else { 'Newsroom' }
		sort_by: if args.sort_by != .@none { args.sort_by } else { .date }
=======
	news_section := Section{
		...args.Section
		name: 'newsroom'
		title: if args.title != '' { args.title } else { 'Newsroom' }
<<<<<<< HEAD
		sort_by: if args.sort_by != .@none { args.sort_by } else { .weight }
>>>>>>> e61681d (example fix wip)
=======
		sort_by: if args.sort_by != .@none { args.sort_by } else { .date }
>>>>>>> 2007ff6 (fix sections processing)
		template: if args.template != '' { args.template } else { 'layouts/newsroom.html' }
		page_template: if args.page_template != '' { args.page_template } else { 'newsPage.html' }
		paginate_by: if args.paginate_by != 0 { args.paginate_by } else { 3 }
	}

	site.add_section(news_section)!
}

pub struct ArticleAddArgs {
<<<<<<< HEAD
<<<<<<< HEAD
mut:
=======
	mut:
>>>>>>> e61681d (example fix wip)
=======
mut:
>>>>>>> 2007ff6 (fix sections processing)
	name       string
	collection string @[required]
	file       string @[required]
	image      string
	pointer    string
<<<<<<< HEAD
<<<<<<< HEAD
	page       string
=======
	page    string
>>>>>>> e61681d (example fix wip)
=======
	page       string
>>>>>>> 2007ff6 (fix sections processing)
}

pub fn (mut site ZolaSite) article_add(args ArticleAddArgs) ! {
	article := site.get_article(args)!

	if 'newsroom' !in site.sections {
		site.news_add()!
	}

<<<<<<< HEAD
<<<<<<< HEAD
	image := article.image or { return error('Article must have an image') }

	news_page := new_page(
		name: article.name
		Page: article.page or { return error('article page for ${article.name} not found') }
		title: article.title
		authors: article.authors
		description: article.description
		taxonomies: {
			'people':        article.authors
			'tags':          article.tags
			'news-category': article.categories
		}
		date: article.date.time()
		assets: [article.image?.path]
		extra: {
			'imgPath': image.file_name()
		}
	)!

=======
=======
	image := article.image or { return error('Article must have an image') }

>>>>>>> 2007ff6 (fix sections processing)
	news_page := new_page(
		name: article.name
		Page: article.page or { return error('article page for ${article.name} not found') }
		title: article.title
		authors: article.authors
		description: article.description
		taxonomies: {
			'people':        article.authors
			'tags':          article.tags
			'news-category': article.categories
		}
		date: article.date.time()
		assets: [article.image?.path]
		extra: {
			'imgPath': image.file_name()
		}
	)!

>>>>>>> e61681d (example fix wip)
	site.sections['newsroom'].page_add(news_page)!
}

fn (site ZolaSite) get_article(args_ ArticleAddArgs) !Article {
	if args_.pointer == '' && (args_.collection == '' || args_.page == '') {
		return error('Either pointer or post collection and page must be specified in order to add post')
<<<<<<< HEAD
	}

	mut args := args_
	if args.collection == '' {
		args.collection = args.pointer.split(':')[0]
	}

	// check collection exists
	_ = site.tree.collection_get(args.collection) or {
		return error('Collection ${args.collection} not found.')
=======
	}

	mut args := args_
	if args.collection == '' {
		args.collection = args.pointer.split(':')[0]
	}

	// check collection exists
	_ = site.tree.collection_get(args.collection) or {
		return error('Collection ${args.collection} not found.')
	}

	if args.pointer == '' {
		args.pointer = '${args.collection}:${args.name}'
	}

<<<<<<< HEAD
	mut page := site.tree.page_get(args.pointer) or {
		return err
>>>>>>> e61681d (example fix wip)
	}
=======
	mut page := site.tree.page_get(args.pointer) or { return err }
>>>>>>> 2007ff6 (fix sections processing)

	if args.pointer == '' {
		args.pointer = '${args.collection}:${args.name}'
	}

	mut page := site.tree.page_get(args.pointer) or { return err }

	actions := page.doc()!.actions()

	article_definitions := actions.filter(it.name == 'article_define')
	if article_definitions.len == 0 {
		return error('specified file does not include a article definition.')
	}
	if article_definitions.len > 1 {
		return error('specified file includes multiple article definitions')
	}

	definition := article_definitions[0]
	page_ := definition.params.get_default('page_path', '')!
	image_ := definition.params.get_default('image_path', '')!
	authors_ := definition.params.get_list_default('authors', [])!

	mut article := Article{
		page: page
		cid: definition.params.get_default('cid', '')!
		name: definition.params.get_default('name', '')!
<<<<<<< HEAD
<<<<<<< HEAD
		categories: definition.params.get_list_default('categories', [])!
		tags: definition.params.get_list_default('tags', [])!
=======
>>>>>>> e61681d (example fix wip)
=======
		categories: definition.params.get_list_default('categories', [])!
		tags: definition.params.get_list_default('tags', [])!
>>>>>>> 2007ff6 (fix sections processing)
		title: definition.params.get_default('title', '')!
		description: definition.params.get_default('description', '')!
		date: definition.params.get_time_default('date', ourtime.now())!
		authors: authors_
		page_path: definition.params.get_default('page_path', '')!
	}

	if article.cid == '' {
		return error('articles cid cant be empty')
	}

	// add image and page to article if they exist
	if page_ != '' {
		article = Article{
			...article
<<<<<<< HEAD
<<<<<<< HEAD
			page: site.tree.page_get('${args.collection}:${page_}') or { return err }
		}
	}

	// // add image and page to article if they exist
	if image_ != '' {
		article = Article{
			...article
			image: site.tree.image_get('${args.collection}:${image_}') or { return err }
=======
			page: site.tree.page_get('${args.collection}:${page_}') or {
				return err
			}
=======
			page: site.tree.page_get('${args.collection}:${page_}') or { return err }
>>>>>>> 2007ff6 (fix sections processing)
		}
	}

	// // add image and page to article if they exist
	if image_ != '' {
		article = Article{
			...article
<<<<<<< HEAD
			image: site.tree.image_get('${args.collection}:${image_}') or {
				println(err)
				return err
			}
>>>>>>> e61681d (example fix wip)
=======
			image: site.tree.image_get('${args.collection}:${image_}') or { return err }
>>>>>>> 2007ff6 (fix sections processing)
		}
	}

	return article
<<<<<<< HEAD
<<<<<<< HEAD
}
=======
}
>>>>>>> e61681d (example fix wip)
=======
}
>>>>>>> 2007ff6 (fix sections processing)
