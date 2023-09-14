module params
import freeflowuniverse.crystallib.texttools
import regex

// convert GB, MB, KB to bytes
// e.g. 10 GB becomes bytes in u64
pub fn (mut params Params) replace(args map[string]string) {

	for mut p in params.params{
		for i in regexfind(p.value){
			i2:=texttools.name_fix(i)
			if i2 in args{
				// println("$i -> ${args[i2]}")
				p.value=p.value.replace(i,args[i2])
			}
		}
	}

}


fn regexfind(txt string) []string{
	pattern := r'\{(\w+)\}'
	mut re := regex.regex_opt(pattern) or { panic(err) }
	// println(re.get_query())
	mut words:= re.find_all_str(txt) 
	// println(words)
	return words
}

// func main() {
// 	// Sample string
// 	str := "This is a sample string with ${ROOT} and another ${ROOT} instance."

// 	// Regex pattern to match `${ROOT}`
// 	pattern := `\$\\{(\w+)\\}`
// 	re := regexp.MustCompile(pattern)

// 	// Find all matches
// 	matches := re.FindAllStringSubmatch(str, -1)

// 	// Iterate over matches and print the captured group
// 	for _, match := range matches {
// 		if len(match) > 1 {
// 			fmt.Println(match[1]) // This will print "ROOT" for each instance found
// 		}
// 	}
// }