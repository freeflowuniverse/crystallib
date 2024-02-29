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
		assert link.id == 3
		assert link.processed == true
		assert link.type_name == 'link'
		assert link.content == '[Architecture](architecture/architecture.md)'
		assert link.cat == .page
		assert link.isexternal == false
		assert link.include == false
		assert link.newtab == false
		assert link.moresites == false
		assert link.description == 'Architecture'
		assert link.url == 'architecture/architecture.md'
		assert link.filename == 'architecture.md'
		assert link.path == 'architecture'
		assert link.site == ''
		assert link.extra == ''
		assert link.state == .ok
		assert link.error_msg == ''
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
		assert link.id == 3
		assert link.processed == true
		assert link.type_name == 'link'
		assert link.content == '[Architecture](@*!architecture/architecture.md)'
		assert link.cat == .page
		assert link.isexternal == false
		// assert link.newtab == true
		// assert link.moresites == true
		assert link.description == 'Architecture'
		assert link.url == '@*!architecture/architecture.md'
		assert link.filename == 'architecture.md'
		assert link.path == '@*!architecture'
		assert link.site == ''
		assert link.extra == ''
		assert link.state == .ok
		assert link.error_msg == ''
	} else {
		assert false, 'last paragraph element is not a link: ${link}'
	}
	assert '[Architecture](@*!architecture/architecture.md)' == link.markdown()!
}

fn test_link3() {
	mut docs := new(content: "[AArchitecture](./img/license_threefoldfzc.png ':size=800x900')")!

	assert docs.children.len == 1
	assert docs.children[0] is elements.Paragraph
	paragraph := docs.children[0]
	assert paragraph.children.len == 1
	link := paragraph.children[0]
	if link is elements.Link {
		assert link.id == 3
		assert link.processed == true
		assert link.type_name == 'link'
		assert link.content == "[AArchitecture](./img/license_threefoldfzc.png ':size=800x900')"
		assert link.cat == .image
		assert link.isexternal == false
		assert link.include == false
		assert link.newtab == false
		assert link.moresites == false
		assert link.description == 'AArchitecture'
		assert link.url == "./img/license_threefoldfzc.png ':size=800x900'"
		assert link.filename == 'license_threefoldfzc.png'
		assert link.path == 'img'
		assert link.site == ''
		assert link.extra == "':size=800x900'"
		assert link.state == .ok
		assert link.error_msg == ''
	} else {
		assert false, 'last paragraph element is not a link: ${link}'
	}
	assert "[AArchitecture](./img/license_threefoldfzc.png ':size=800x900')" == link.markdown()!
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
		assert link.id == 3
		assert link.processed == true
		assert link.type_name == 'link'
		assert link.content == '[Architecture](https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd)'
		assert link.cat == .html
		assert link.isexternal == true
		assert link.include == false
		assert link.newtab == false
		assert link.moresites == false
		assert link.description == 'Architecture'
		assert link.url == 'https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd'
		assert link.filename == ''
		assert link.path == ''
		assert link.site == ''
		assert link.extra == ''
		assert link.state == .ok
		assert link.error_msg == ''
	} else {
		assert false, 'last paragraph element is not a link: ${link}'
	}
	assert '[Architecture](https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd)' == link.markdown()!
}

// // TODO add more tests
