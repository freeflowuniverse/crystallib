module markdowndocs

import pathlib

fn test_link1() {
	mut docs := new(content: '[Architecture](architecture/architecture.md)')!

	docscompare := Doc{
		content: '[Architecture](architecture/architecture.md)'
		items: [
			DocItem(Paragraph{
				content: '[Architecture](architecture/architecture.md)'
				items: [
					ParagraphItem(Link{
						content: '[Architecture](architecture/architecture.md)'
						cat: .page
						isexternal: false
						include: false
						newtab: false
						moresites: false
						description: 'Architecture'
						url: 'architecture/architecture.md'
						filename: 'architecture.md'
						path: 'architecture'
						site: ''
						extra: ''
						state: .ok
						error_msg: ''
					}),
				]
				changed: false
			}),
		]
		path: pathlib.Path{
			path: ''
			cat: .unknown
			exist: .unknown
		}
	}

	assert docscompare == docs
}

fn test_link2() {
	mut docs := new(content: '[Architecture](@*!architecture/architecture.md)')!

	paragr := docs.items[0]
	if paragr is Paragraph {
		link := paragr.items[0]
		if link is Link {
			assert '[Architecture](*!@architecture/architecture.md)' == link.wiki()
			assert link == Link{
				content: '[Architecture](@*!architecture/architecture.md)'
				cat: .page
				isexternal: false
				include: true
				newtab: true
				moresites: true
				description: 'Architecture'
				url: '@*!architecture/architecture.md'
				filename: 'architecture.md'
				path: 'architecture'
				site: ''
				extra: ''
				state: .ok
				error_msg: ''
			}
			return
		}
	}

	panic('error, should not get here')
}

fn test_link3() {
	mut docs := new(content: "[AArchitecture](./img/license_threefoldfzc.png ':size=800x900')")!

	paragr := docs.items[0]
	if paragr is Paragraph {
		link := paragr.items[0]
		if link is Link {
			assert "![AArchitecture](img/license_threefoldfzc.png ':size=800x900')" == link.wiki()
			assert link == Link{
				content: "[AArchitecture](./img/license_threefoldfzc.png ':size=800x900')"
				cat: .image
				isexternal: false
				include: false
				newtab: false
				moresites: false
				description: 'AArchitecture'
				url: "./img/license_threefoldfzc.png ':size=800x900'"
				filename: 'license_threefoldfzc.png'
				path: 'img'
				site: ''
				extra: "':size=800x900'"
				state: .ok
				error_msg: ''
			}
			return
		}
	}

	panic('error, should not get here')
}

fn test_link4() {
	mut docs := new(
		content: '[Architecture](https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd)'
	)!

	paragr := docs.items[0]
	if paragr is Paragraph {
		link := paragr.items[0]
		if link is Link {
			assert '[Architecture](https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd)' == link.wiki()
			assert link == Link{
				content: '[Architecture](https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd)'
				cat: .html
				isexternal: true
				include: false
				newtab: false
				moresites: false
				description: 'Architecture'
				url: 'https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd'
				filename: ''
				path: ''
				site: ''
				extra: ''
				state: .ok
				error_msg: ''
			}
			return
		}
	}

	panic('error, should not get here')
}

//> TODO: some more tests like below with mutliple links in 1 line ...

// fn test_link7() {
// 	mut lp := LinkParseResult{}
// 	mut para := Paragraph{}
// 	lp = para.link_parser('
// 		hi [Architecture](mysite:new/newer.md) is something else [Something](yes/start.md)
// 		line
// 		 [Something](yes/start.md)
// 	') or {
// 		panic(err)
// 	}

// 	correct_lp := LinkParseResult{
// 		links: [
// 			Link{
// 				content: '[Architecture](mysite:new/newer.md)'
// 				cat: .page
// 				isexternal: false
// 				include: true
// 				newtab: false
// 				moresites: false
// 				description: 'Architecture'
// 				url: ''
// 				filename: 'newer.md'
// 				path: 'new'
// 				site: 'mysite'
// 				extra: ''
// 				state: .ok
// 				error_msg: ''
// 			},
// 			Link{
// 				content: '[Something](yes/start.md)'
// 				cat: .page
// 				isexternal: false
// 				include: true
// 				newtab: false
// 				moresites: false
// 				description: 'Something'
// 				url: ''
// 				filename: 'start.md'
// 				path: 'yes'
// 				site: ''
// 				extra: ''
// 				state: .ok
// 				error_msg: ''
// 			},
// 			Link{
// 				content: '[Something](yes/start.md)'
// 				cat: .page
// 				isexternal: false
// 				include: true
// 				newtab: false
// 				moresites: false
// 				description: 'Something'
// 				url: ''
// 				filename: 'start.md'
// 				path: 'yes'
// 				site: ''
// 				extra: ''
// 				state: .ok
// 				error_msg: ''
// 			},
// 		]
// 	}

// 	assert lp.str() == correct_lp.str()
// }
