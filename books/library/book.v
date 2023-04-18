module library

import freeflowuniverse.crystallib.texttools

[heap]
pub struct Book {
pub mut:
	name string
	sid string
	chapters map[string]&Chapter
	library &Library [str: skip]
	state BookState
}

pub enum BookState{
	init
	ok 
	error
}


pub struct ChapterNotFound {
	Error
pub:
	pointer Pointer
	book &Book
	msg string
}

pub fn (err ChapterNotFound) msg() string {
	if err.msg.len>0{
		return err.msg
	}	
	chapternames := err.book.chapternames().join('\n- ')
	return '"Cannot not find chapter from book:${err.book.name}.\nPointer: ${err.pointer}.\nKnown Chapters:\n${chapternames}'
}


pub fn (mut book Book) chapter_exists(name string) bool {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if  namelower in book.chapters {
		return true
	}
	return false
}

// fix all loaded library
pub fn (mut book Book) fix() ! {
	if book.state == .ok {
		return
	}
	for _, mut ch in book.chapters {
		ch.fix()!
	}
}

pub fn (book Book) chapternames() []string {
	mut res := []string{}
	for _,chapter in book.chapters {
		res << chapter.name
	}
	res.sort()
	return res
}


// internal function
fn (mut book Book) chapter_get_from_pointer(p Pointer) !&Chapter {
	if p.book!="" && p.book!= book.name{
		return ChapterNotFound{
			book:&book
			pointer: p
			msg: "book name was not empty and was not same as book.\n$p"
		}
	}
	mut ch := book.chapters[p.chapter] or { 
		return ChapterNotFound{
			book:&book
			pointer: p
		}
	}	
	return ch	
}

pub fn (mut book Book) chapter_get(name string) !&Chapter {
	p:=pointer_new(name)!
	return book.chapter_get_from_pointer(p)!
}


pub struct NoOrTooManyObjFound {
	Error
pub:
	book &Book
	pointer Pointer
	nr int
}

pub fn (err NoOrTooManyObjFound) msg() string {
	if err.nr>0{
		return 'Too many obj found for ${err.book.name}. Pointer: ${err.pointer}'
	}
	return 'No obj found for ${err.book.name}. Pointer: ${err.pointer}'
}


// get the page from pointer string: $book:$chapter:$name or
// $chapter:$name or $name
pub fn (mut book Book) page_get(pointerstr string) !&Page {
	p:=pointer_new(pointerstr)!
	mut res := []&Page{}
	for _,chapter in book.chapters{
		if p.chapter=="" || p.chapter==chapter.name{
			if chapter.page_exists(pointerstr){
				res<<chapter.page_get(pointerstr) or {panic("BUG")}
			}
		}
	}
	if res.len==1{
		return res[0]
	}else{
		return NoOrTooManyObjFound{book:&book,pointer:p,nr:res.len}
	}

}


// get the page from pointer string: $book:$chapter:$name or
// $chapter:$name or $name
pub fn (mut book Book) image_get(pointerstr string) !&File {
	p:=pointer_new(pointerstr)!
	mut res := []&File{}
	for _,chapter in book.chapters{
		if p.chapter=="" || p.chapter==chapter.name{
			if chapter.image_exists(pointerstr){
				res<<chapter.image_get(pointerstr) or {panic("BUG")}
			}
		}
	}
	if res.len==1{
		return res[0]
	}else{
		return NoOrTooManyObjFound{book:&book,pointer:p,nr:res.len}
	}
}

// get the file from pointer string: $book:$chapter:$name or
// $chapter:$name or $name
pub fn (mut book Book) file_get(pointerstr string) !&File {
	p:=pointer_new(pointerstr)!
	mut res := []&File{}
	for _,chapter in book.chapters{
		if p.chapter=="" || p.chapter==chapter.name{
			if chapter.file_exists(pointerstr){
				res<<chapter.file_get(pointerstr) or {panic("BUG")}
			}
		}
	}
	if res.len==1{
		return res[0]
	}else{
		return NoOrTooManyObjFound{book:&book,pointer:p,nr:res.len}
	}
}

//exists or too many
pub fn (mut book Book) page_exists(name string) bool {
	_ := book.page_get(name) or {
		if err is ChapterNotFound || err is ChapterObjNotFound || err is NoOrTooManyObjFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}

//exists or too many
pub fn (mut book Book) image_exists(name string) bool {
	_ := book.image_get(name) or {
		if err is ChapterNotFound || err is ChapterObjNotFound  || err is NoOrTooManyObjFound{
			return false
		} else {
			panic(err)
		}
	}
	return true
}

//exists or too many
pub fn (mut book Book) file_exists(name string) bool {
	_ := book.file_get(name) or {
		if err is ChapterNotFound || err is ChapterObjNotFound  || err is NoOrTooManyObjFound{
			return false
		} else {
			panic(err)
		}
	}
	return true
}

