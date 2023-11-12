module markdownparser

fn test_link1() {
	mut docs := new(content: '[Architecture](architecture/architecture.md)')!

	assert docs.elements.len == 1
	assert docs.elements[0] is Paragraph
	paragraph := docs.elements[0] as Paragraph
	assert paragraph.elements.len == 1
	assert paragraph.elements[0] is Link
	link := paragraph.elements[0] as Link
	assert link == Link{
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
}

fn test_link2() {
	mut docs := new(content: '[Architecture](@*!architecture/architecture.md)')!

	assert docs.elements.len == 1
	assert docs.elements[0] is Paragraph
	paragraph := docs.elements[0] as Paragraph
	assert paragraph.elements.len == 1
	assert paragraph.elements[0] is Link
	link := paragraph.elements[0] as Link
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
	assert '[Architecture](*!@architecture/architecture.md)' == link.wiki()
}

fn test_link3() {
	mut docs := new(content: "[AArchitecture](./img/license_threefoldfzc.png ':size=800x900')")!

	assert docs.elements.len == 1
	assert docs.elements[0] is Paragraph
	paragraph := docs.elements[0] as Paragraph
	assert paragraph.elements.len == 1
	assert paragraph.elements[0] is Link
	link := paragraph.elements[0] as Link
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
	assert "![AArchitecture](img/license_threefoldfzc.png ':size=800x900')" == link.wiki()
}

fn test_link4() {
	mut docs := new(
		content: '[Architecture](https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd)'
	)!

	assert docs.elements.len == 1
	assert docs.elements[0] is Paragraph
	paragraph := docs.elements[0] as Paragraph
	assert paragraph.elements.len == 1
	assert paragraph.elements[0] is Link
	link := paragraph.elements[0] as Link
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
	assert '[Architecture](https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd)' == link.wiki()
}

// TODO add more tests
