module markdownparser

import freeflowuniverse.crystallib.data.markdownparser.elements

fn test_link1() {
	mut docs := new(content: '[Architecture](architecture/architecture.md)')!

	assert docs.children.len == 1
	assert docs.children[0] is elements.Paragraph
	paragraph := docs.children[0]
	assert paragraph.children.len == 1
	link := paragraph.children[0]
	if link is elements.Link {
		assert *link == elements.Link{
			id: 3
			processed: true
			type_name: 'link'
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
		}
	} else {
		assert false, 'last paragraph element is not a link: ${link}'
	}
}

fn test_link2() {
	mut docs := new(content: '[Architecture](@*!architecture/architecture.md)')!

	assert docs.children.len == 1
	assert docs.children[0] is elements.Paragraph
	paragraph := docs.children[0]
	assert paragraph.children.len == 1
	link := paragraph.children[0]

	if link is elements.Link {
		assert *link == elements.Link{
			id: 3
			processed: true
			type_name: 'link'
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
	} else {
		assert false, 'last paragraph element is not a link: ${link}'
	}
	assert '[Architecture](*!@architecture/architecture.md)' == link.markdown()
}

fn test_link3() {
	mut docs := new(content: "[AArchitecture](./img/license_threefoldfzc.png ':size=800x900')")!

	assert docs.children.len == 1
	assert docs.children[0] is elements.Paragraph
	paragraph := docs.children[0]
	assert paragraph.children.len == 1
	link := paragraph.children[0]
	if link is elements.Link {
		assert link == elements.Link{
			id: 3
			processed: true
			type_name: 'link'
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
	} else {
		assert false, 'last paragraph element is not a link: ${link}'
	}
	assert "![AArchitecture](img/license_threefoldfzc.png ':size=800x900')" == link.markdown()
}

fn test_link4() {
	mut docs := new(
		content: '[Architecture](https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd)'
	)!

	assert docs.children.len == 1
	assert docs.children[0] is elements.Paragraph
	paragraph := docs.children[0]
	assert paragraph.children.len == 1
	link := paragraph.children[0]
	if link is elements.Link {
		assert link == elements.Link{
			id: 3
			processed: true
			type_name: 'link'
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
	} else {
		assert false, 'last paragraph element is not a link: ${link}'
	}
	assert '[Architecture](https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd)' == link.markdown()
}

// TODO add more tests
