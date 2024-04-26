module zola

// adds a news section to the zola site
fn test_news_add() ! {
	mut sites := new()!
	mut site := sites.new(name: @FILE)!
	site.news_add()!
}
