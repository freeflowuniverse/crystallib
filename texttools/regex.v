module texttools

import regex
import os
struct ReplaceInstructions {
pub mut:
	instructions []ReplaceInstruction
}

struct ReplaceInstruction {
pub:
	regex_str    string
	find_str     string
	replace_with string
pub mut:
	regex regex.RE
}

fn (mut self ReplaceInstructions) get_regex_queries() []string {
	mut res := []string{}
	for i in self.instructions {
		res << i.regex.get_query()
	}
	return res
}

fn regex_rewrite(r string) ?string {
	r2 := r.to_lower()
	mut res := []string{}
	for char in r2 {
		mut c := char.ascii_str()
		if 'abcdefghijklmnopqrstuvwxyz'.contains(c) {
			char_upper := c.to_upper()
			res << '[' + c + char_upper + ']'
		} else if '0123456789'.contains(c) {
			res << c
		} else if '_- '.contains(c) {
			// res << r"\[\\s _\\-\]*"
			res << r' *'
		} else if '\'"'.contains(c) {
			continue
		} else if '^&![]'.contains(c) {
			return error('cannot rewrite regex: $r, found illegal char ^&![]')
		}
	}
	return res.join('')
	//+r"[\\n \:\!\.\?;,\\(\\)\\[\\]]"
}

// regex string see https://github.com/vlang/v/blob/master/vlib/regex/README.md
// find_str is a normal search (text)
// replace is the string we want to replace the match with
fn (mut self ReplaceInstructions) add_item(regex_find_str string, replace_with string) ? {
	mut item := regex_find_str
	if item.starts_with('^R') {
		item = item[2..] // remove ^r
		r := regex.regex_opt(item) ?
		self.instructions << ReplaceInstruction{
			regex_str: item
			regex: r
			replace_with: replace_with
		}
	} else if item.starts_with('^S') {
		item = item[2..] // remove ^S
		item2 := regex_rewrite(item) ?
		r := regex.regex_opt(item2) ?
		self.instructions << ReplaceInstruction{
			regex_str: item
			regex: r
			replace_with: replace_with
		}
	} else {
		self.instructions << ReplaceInstruction{
			replace_with: replace_with
			find_str: item
		}
	}
}

//
// input is ["^Rregex:replacewith",...]
// input is ["^Rregex:^Rregex2:replacewith"]
// input is ["findstr:findstr:replacewith"]
// input is ["findstr:^Rregex2:replacewith"]
// findstr is a normal string to look for, is always matched case insensitive
// regex is regex as described in https://github.com/vlang/v/blob/master/vlib/regex/README.md
//   regex start with ^R
//   case insensitive regex start with ^S
pub fn (mut ri ReplaceInstructions) add(replacelist []string) ? {
	for i in replacelist {
		splitted := i.split(':')
		replace_with := splitted[splitted.len - 1]
		// last one not to be used
		if splitted.len < 2 {
			return error("Cannot add $i because needs to have 2 parts, wrong syntax, to regex instructions:\n\"$replacelist\"")
		}
		for item in splitted[0..(splitted.len - 1)] {
			ri.add_item(item, replace_with) ?
		}
	}
}

pub struct ReplaceArgs{
pub mut:
	text string
	dedent bool 
}

// does the matching line per line
// will use dedent function, on text
pub fn (mut self ReplaceInstructions) replace(args ReplaceArgs) ?string {
	mut gi := 0
	mut text2 := args.text
	if args.dedent{
		text2 = dedent(text2)
	}
	mut line2 := ''
	mut res := []string{}
	// println('AAA\n$text\nBBB\n')
	if text2.len == 0 {
		return ""
	}
	//check if there is \n at end of text, because of splitlines would be lost
	mut endline:=false
	if text2.ends_with("\n"){
		endline=true
	}
	for line in text2.split_into_lines() {
		line2 = line
		// println(' >>>> $line')
		// mut tl := tokenize(line)
		// println(tl)
		for mut i in self.instructions {
			if i.find_str == '' {
				// println('REGEX:' + i.regex.get_query() + ' <-$line')
				all := i.regex.find_all(line)
				for gi < all.len {
					// println('  >> "${line[all[gi]..all[gi + 1]]}"')
					gi += 2
				}
				line2 = i.regex.replace(line2, i.replace_with)
				// println('REPLACE_R:${i.regex.get_query()}:$line:$line2')
			} else {
				// println(tl)
				// line2 = line2.replace(i.find_str, i.replace_with)
				// line2 = tl.replace(line2, i.find_str, i.replace_with) ?
				// println('REPLACE:$i.find_str -> $line -> $line2')

				line2 = line2.replace(i.find_str,i.replace_with)

			}
		}
		res << line2
	}
	// println('AAA2\n$text2\nBBB2\n')
	mut x := res.join('\n')
	if ! endline{
		x=x.trim_right("\n")
	}
	return x
}

pub struct ReplaceDirArgs{
pub mut:	
	path path.Path
	extensions []string
	dryrun bool
}
//if dryrun is true then will not replace but just show
pub fn (mut self ReplaceInstructions) replace_in_dir(args ReplaceDirArgs) ?int {
	mut count := 0
	//create list of unique extensions all lowercase
	mut extensions := []string{}
	for ext in args.extensions{
		if ! (ext in extensions){
			mut ext2 := ext.to_lower()
			if ext2.starts_with("."){
				ext2 = ext2[1..]
			}
			extensions << ext2
		}
	}

	mut done := []string{}
	count += self.replace_in_dir_recursive(args.path, extensions, args.dryrun, mut done) ?
	return count
}


//returns how many files changed
fn (mut self ReplaceInstructions) replace_in_dir_recursive(path1 string, extensions []string, dryrun bool, mut done []string) ?int {
	items := os.ls(path1) or { return error('cannot load folder for replace because cannot find $path1') }
	mut pathnew := ''
	mut count := 0

	for item in items {
		pathnew = os.join_path(path1, item)
		// CAN DO THIS LATER IF NEEDED
		// if pathnew in done{
		// 	continue
		// }
		// done << pathnew
		if os.is_dir(pathnew) {
			// println(" - $pathnew")		
			if item.starts_with('.') {
				continue
			}
			if item.starts_with('_') {
				continue
			}

			self.replace_in_dir_recursive(pathnew, extensions, dryrun, mut done) ?
		}else{			
			ext := os.file_ext(pathnew)[1..].to_lower()
			if extensions==[] || ext in extensions{
				//means we match a file
				// println (" . replace: $pathnew ($ext)")
				txtold := os.read_file(pathnew)?
				txtnew := self.replace(text:txtold,dedent:false)?
				if txtnew.trim(" \n") == txtold.trim(" \n"){
					println(" - nothing to do : $pathnew")
				}else{
					println(" - replace done  : $pathnew")
					count ++
					if ! dryrun{
						//now write the file back
						os.write_file(pathnew,txtnew)?
					}
					// println("===========")
					// println(txtold)
					// println("===========")
					// println(txtnew)
					// println("===========")
				}
			}
		}
	}
	return count
}



pub fn regex_instructions_new() ReplaceInstructions {
	return ReplaceInstructions{}
}
