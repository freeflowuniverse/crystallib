module library

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

fn test_pointerpath() {
	p1 := pointerpath_new(path: '/tmp/A file.md') or { panic(err) }
	println(p1)
	p1_compare := PointerPath{
		pointer: Pointer{
			chapter: ''
			name: 'a_file'
			cat: .page
			extension: 'md'
			book: ''
			error: ''
			state: .unknown
		}
		path: pathlib.Path{
			path: '/tmp/A file.md'
			cat: .unknown
			exist: .no
		}
	}
	assert p1 == p1_compare

	p2 := pointerpath_new(path: '/tmp/ss/A__file.jpeg') or { panic(err) }
	p2_compare := PointerPath{
		pointer: Pointer{
			chapter: ''
			name: 'a_file'
			cat: .image
			extension: 'jpeg'
			book: ''
			error: ''
			state: .unknown
		}
		path: pathlib.Path{
			path: '/tmp/A__file.jpeg'
			cat: .unknown
			exist: .no
		}
	}

	// assert p2==p2_compare
}

fn test_pointer() {
	p := pointer_new('Page__.md') or { panic(err) }
	println(p)
	p_compare := Pointer{
		chapter: ''
		name: 'page'
		cat: .page
		extension: 'md'
		book: ''
		error: ''
		state: .unknown
	}
	assert p == p_compare
}

fn test_pointer2() {
	p := pointer_new('chapterAAA:Page__.md') or { panic(err) }
	println(p)
	p_compare := Pointer{
		name: 'page'
		cat: .page
		extension: 'md'
		chapter: 'chapteraaa'
		book: ''
		error: ''
		state: .unknown
	}
	assert p == p_compare
}

fn test_pointer3() {
	p := pointer_new('MY_Book:chapter_AAA:Page__.md') or { panic(err) }
	println(p)
	p_compare := Pointer{
		name: 'page'
		cat: .page
		extension: 'md'
		chapter: 'chapter_aaa'
		book: 'my_book'
		error: ''
		state: .unknown
	}
	assert p == p_compare
}

fn test_pointer4() {
	p := pointer_new('MY_Book:chapter_AAA:aImage__.jpg') or { panic(err) }
	println(p)
	p_compare := Pointer{
		chapter: ''
		name: 'aimage'
		cat: .image
		extension: 'jpg'
		chapter: 'chapter_aaa'
		book: 'my_book'
		error: ''
		state: .unknown
	}
	assert p == p_compare
}

fn test_pointer5() {
	p := pointer_new('MY_Book::aImage__.jpg') or { panic(err) }
	println(p)
	p_compare := Pointer{
		chapter: ''
		name: 'aimage'
		cat: .image
		extension: 'jpg'
		chapter: ''
		book: 'my_book'
		error: ''
		state: .unknown
	}
	assert p == p_compare
}

fn test_pointer6() {
	p := pointer_new('MY_Book::aImage__.jpg') or { panic(err) }
	assert p.str() == 'my_book::aimage.jpg'

	p2 := pointer_new('ddd:aImage__.jpg') or { panic(err) }
	assert p2.str() == 'ddd:aimage.jpg'

	p3 := pointer_new('aImage__.jpg') or { panic(err) }
	assert p3.str() == 'aimage.jpg'

	i := 40
	p4 := pointer_new('chapterAAA:Page__${i}.md') or { panic(err) }
	assert p4.str() == 'chapteraaa:page_40.md'
}

fn test_pointer7() {
	r := texttools.name_fix_keepext('page_40.md')
	assert r == 'page_40.md'
}
