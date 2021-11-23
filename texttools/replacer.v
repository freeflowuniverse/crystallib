module texttools

//check the ch is in a...Z0..9
fn is_var_char(ch string) bool{
	if 'abcdefghijklmnopqrstuvwxyz0123456789_-'.contains(ch.to_lower()){
		return true
	} 
	return false
}

// the map has as key the normalized string (fix_name_no_underscore), the value is what to replace with
pub fn replace_items(text string, replacer map[string]string) string {
	mut skipline := false
	mut res := []string{}
	mut keys := []string{}
	mut var := ""
	mut ch := ""
	mut skipline_format := ""
	toskip := "/.|:'`"
	// mut done := []string{}

	mut replacer2 :=  map[string]string{}

	for key, _ in replacer {
		keys << key
	}

	for key in keys {
		key2 := texttools.name_fix_no_underscore_token(key)
		replacer2[key2] = replacer[key]
	}

	text_lines := text.split('\n')

	for line in text_lines {
		//println(" - '$line'")
		if line.trim(' ').starts_with('!') {
			res << line
			continue
		}
		if line.trim(' ').starts_with('|') {
			res << line
			continue
		}		
		if line.trim(' ').starts_with('/') {
			res << line
			continue
		}
		if line.trim(' ').starts_with('#') {
			res << line
			continue
		}
		if line.trim(' ').starts_with('<!-') {
			res << line
			continue
		}
		
		for skipsearch in ["'''",'```','"""']{
			if line.contains(skipsearch){
				skipline = !skipline
				skipline_format = skipsearch
				break
			}
		}

		if skipline {
			res << line
			continue
		}

		var = ""
		mut prevchar := ""
		mut is_comment := false
		mut is_possible_link := false
		mut is_link := false
		mut line_out := ""
		mut var_skip := false
		for char_ in line.split('') {
			ch = char_

			if toskip.contains(ch){
				//this means that the next var cannot be used
				var_skip = true
			}
			if ch == "["{
				//println(" ++++ is_possible_link")
				is_possible_link = true
			}
			if prevchar=="]" && ch=="(" && is_possible_link{
				//println(" ++++ islink")
				is_link = true
			}
			//end of link
			if ch==")" && is_link{
				is_link = false
				is_possible_link = false
				line_out += ch
				//println("++++ end link")
				prevchar = ch
				ch = ""
				continue
			}
			if is_possible_link || is_link  || is_comment {
				line_out += ch
				prevchar = ch
				continue
			}
			//println(" -- char:'$ch'")
			if is_var_char(ch){
				if var_skip{
					line_out += ch
					prevchar = ch
					ch = ""
					continue					
				}else{
					var+=ch
					//println(" -- var:'$var'")
				}
			}else{				
				//means we have potentially found a var, now ch not part of var
				//println(" -- varsubst:${varsubst(ch, var, replacer2)}")
				line_out += varsubst(ch, var, replacer2)
				var = ""
				if ! toskip.contains(ch){
					var_skip = false
				}				
			}
			prevchar = ch
			ch = ""
		}
		//println(" --- endline: lastchar:'$ch' varsubst:${varsubst(ch, var, replacer2)}")
		if var!=""{
			line_out += varsubst(ch, var, replacer2)
		}
		//println(" -> ${line_out}")
		res << line_out
	}
	if skipline{
		res << skipline_format
		res << "<br>"
	}
	final_res := res.join('\n')	

	return final_res
}

fn varsubst(ch string, var string, replacer map[string]string )string {
	if var.len>0{
		//yes we found a var
		var2 := texttools.name_fix_no_underscore_token(var)
		if var2 in replacer{
			return replacer[var2]+ch
		}
		return var+ch
	}else{
		return ch
	}
}