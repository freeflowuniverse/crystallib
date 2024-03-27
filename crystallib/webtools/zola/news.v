module zola

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.core.texttools

// News section for Zola site
pub struct News {
	sort_by SortBy = .date
mut:
	articles map[string]Article
}

@[params]
pub struct NewsAddArgs {}

pub struct Article {
pub:
	cid         string          @[required]
	title       string
	name        string
	image       ?&doctree.File
	tags        []string
	authors     []Person
	categories  []string
	date        ourtime.OurTime
	page        ?&doctree.Page
	biography   string
	description string
}

// adds a news section to the zola site
fn (mut site ZolaSite) news_add(args NewsAddArgs) ! {
	if _ := site.news {
		return error('News section already exists in zola site')
	} else {
		site.news = News{}
	}
}

fn (mut news News) export(content_dir string) ! {
	news_dir := pathlib.get_dir(
		path: '${content_dir}/newsroom'
		create: true
	)!

	 _ := pathlib.get_file(
		path: '${news_dir.path}/_index.md'
		create: true
	)!
	news_index.write($tmpl('./templates/news.md'))!

	for _, mut article in news.articles {
		article.export(news_dir.path)!
	}
}

pub struct ArticleAddArgs {
	name       string
	collection string @[required]
	file       string @[required]
	image      string
	pointer    string
}

pub fn (mut site ZolaSite) article_add(args ArticleAddArgs) ! {
	mut news := site.news or {
		site.news_add()!
		site.news or { panic('this should never happen') }
	}

	site.tree.process_includes()!

	collection := if args.collection != '' {
		_ = site.tree.collection_get(args.collection) or {
			println(err)
			return err
		}
		args.collection
	} else {
		if args.pointer != '' {
			args.pointer.split(':')[0]
		} else {
			''
		}
	}

	pointer := if args.pointer != '' {
		args.pointer
	} else {
		'${collection}:${args.name}'
	}

	mut page := site.tree.page_get('${pointer}') or {
		println(err)
		return err
	}

	actions := page.doc()!.actions()

	article_definitions := actions.filter(it.name == 'article_define')
	if article_definitions.len == 0 {
		return error('specified file does not include a article definition.')
	}
	if article_definitions.len > 1 {
		return error('specified file includes multiple article definitions')
	}

	definition := article_definitions[0]
	name := definition.params.get_default('name', '')!
	page_ := definition.params.get_default('page', '')!
	image_ := definition.params.get_default('image_path', '')!
	authors_ := definition.params.get_list_default('authors', [])!

	mut authors := []Person{}
	for author in authors_ {
		cid := texttools.name_fix(author)
		people := site.people or { return error('to add authors to news, site must have people') }

		person := people.persons[cid] or { continue }
		authors << person
	}

	mut article := Article{
		cid: definition.params.get_default('cid', '')!
		name: name
		title: definition.params.get_default('title', '')!
		authors: authors
		date: definition.params.get_time_default('date', ourtime.now())!
		description: definition.params.get_default('description', '')!
	}

	// add image and page to article if they exist
	if page_ != '' {
		article = Article{
			...article
			page: site.tree.page_get('${args.collection}:${page_}') or {
				println(err)
				return err
			}
		}
	}

	if image_ != '' {
		article = Article{
			...article
			image: site.tree.image_get('${collection}:${image_}') or {
				println(err)
				return err
			}
		}
	}

	news.articles[article.cid] = article
	site.news = news
}

// this function exports the article to a given folder
pub fn (article Article) export(news_dir string) ! {
	article_dir := pathlib.get_dir(
		path: '${news_dir}/${article.cid}'
		create: true
	)!

	_ := if mut img := article.image {
		img.copy('${article_dir.path}/${img.file_name()}')!
		img.file_name()
	} else {
		''
	}
	_ := pathlib.get_file(
		path: '${article_dir.path}/index.md'
		create: true
	)!

	content := if mut page := article.page {
		page.doc()!.markdown()!
	} else {
		''
	}
	article_page.write($tmpl('./templates/article.md'))!
}
