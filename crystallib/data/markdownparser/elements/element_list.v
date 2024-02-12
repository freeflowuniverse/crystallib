module elements

//has ListItems as children

@[heap]
pub struct List {
	DocBase
pub mut:
	cat ListCat
	interlinespace int //nr of lines in between
}

pub enum ListCat {
	bullet
	star
	nr
}



pub fn (mut self List) process() !int {
	if self.processed {
		return 0
	}
	panic('implement')	
	// pre := self.content.all_before('-')
	// self.depth = pre.len
	// self.content = self.content.all_after_first('- ')

	// self.processed = true
	return 1
}

pub fn (self List) markdown() string {
	panic('implement')
	return ""
}

pub fn (self List) html() string {
	panic('implement')
	// return '<h${self.depth}>${self.content}</h${self.depth}>\n\n'
}





pub fn line_is_list(line string)bool{
	ltrim:=line.trim_space()
	if ltrim==""{return false}
	if ltrim.starts_with('- '){
		return true
	}
	if ltrim.starts_with('* '){
		return true
	}	
	return line_is_list_nr(line)
}

pub fn line_is_list_nr(line string)bool{
	ltrim:=line.trim_space()
	if ltrim==""{return false}
	if ltrim.contains("."){
		return txt_is_nr(ltrim.all_before("."))
	}
	return false
}


pub fn txt_is_nr(txt_ string) bool {
	txt:=txt_.trim_space()
	for u in txt {
		if u > 47 && u < 58 { // see https://www.charset.org/utf-8
			continue
		}
		return false
	}
	return true
}
