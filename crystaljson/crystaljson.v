module crystaljson

import x.json2
import despiegk.crystallib.texttools

const keep_ascii='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-+={}[]"\':;?/>.<,|\\~` '

//rought splitter for json, splits a list of dicts into the text blocks
pub fn json_list(r string, clean bool) []string {
	mut res := []string{}
	mut open_counter := 0
	mut block := []string{}
	mut blocks := []string
	println("JSONLIST: ${r.len}")
	for ch in r {
		mut c := ch.ascii_str()
		// //rough one to debug
		// if clean && ! keep_ascii.contains(c){
		// 	println("SKIP")
		// 	continue
		// }		
		// print(c)
		if c=="{"{
			open_counter += 1
		}
		if c=="}"{
			open_counter -= 1
		}
		// println(open_counter)
		if open_counter>0{
			block << c
			// println(block.len)
		}
		if open_counter==0 && block.len>2{
			blocks << block.join("") +"}"
			block = []string{}
		}
	}
	println("JSONLIST: DONE")
	return blocks
}


//get dict out of json
//if include used (not empty, then will only match on keys given)
pub fn json_dict_any(r string, clean bool, include []string, exclude []string) ?map[string]json2.Any {
	mut r2 := r
	if clean{
		r2=texttools.ascii_clean(r2)
	}
	data_raw := json2.raw_decode(r2) ?
	data := data_raw.as_map()
	return data
}

// enum JsonDictStatus {
// 	start
// 	key
// 	dpsearch  //look for double point
// 	valsearch //look to find the start of val (see what separator is)
// 	val
// 	end
// }

// enum JsonNodeCat {
// 	list
// 	dict
// 	dictitem
// 	str
// 	boolean
// 	integer
// 	float
// }


// pub struct JsonNode {
// pub mut:
// 	key     string
// 	val		string
// 	cat 	JsonNodeCat
// }


// //get dict out of json
// //if include used (not empty, then will only match on keys given)
// pub fn json_dict(r string, clean bool, include []string, exclude []string) map[string]string {
// 	mut res := map[string]string{}
// 	mut state := JsonDictStatus.start
// 	mut key := []string
// 	mut val := []string
// 	sep := "\"" //separator
// 	mut sep_val := ""
// 	mut sep_val_counter := 0 //nr of sep_val's we encountered
// 	for ch in r {
// 		mut c := ch.ascii_str()
// 		if  state != JsonDictStatus.val && c==" "{
// 			//space in between, can ignore
// 			continue
// 		}
// 		if c == sep {
// 			if state == JsonDictStatus.start{
// 				state = JsonDictStatus.key
// 				continue
// 			}else if state == JsonDictStatus.key{
// 				//means we now need to find a separator
// 				state = JsonDictStatus.valsearch
// 				continue
// 			}
// 		}
// 		if  state == JsonDictStatus.key{
// 			key << c
// 		}
// 		if  state == JsonDictStatus.dpsearch{
// 			if c==":"{
// 				state = JsonDictStatus.valsearch
// 				//now we need to look for separator
// 				continue
// 			}
// 		}
// 		if  state == JsonDictStatus.valsearch{
// 			//the empty spaces should be out because of above
// 			sep_val_counter = 1 //restart counting
// 			if c==sep || c=="[" || c=="{" {
// 				sep_val=c				
// 			}	
// 			state = JsonDictStatus.val
// 			if sep_val!=""{
// 				//only continue if there is a separator
// 				continue
// 			}
// 		}

// 		if  state == JsonDictStatus.val{
// 			if sep_val!=""{
// 				if sep_val_counter>0 && c == sep_val{
// 					//lower with 1
// 					sep_val_counter-=1
// 				}
// 				if sep_val_counter == 0 {
// 					//we are at end of the value
// 					sep_val = ""
// 					continue
// 				}
// 				val << c
// 			}else{
// 				//there is no separator for value, need to look for , or }
// 				if c=="," || c=="}"{
// 					state = JsonDictStatus.valend
// 				}else{
// 					val << c
// 				}
// 			}
// 		}

// 		if state == JsonDictStatus.valend {
// 			key.join("")
// 			val.join("")

// 		}






// 	}
// 	println(r)	
// 	if r.len>0{
// 		panic("jshyd7")
// 	}	
// 	return res
// }
