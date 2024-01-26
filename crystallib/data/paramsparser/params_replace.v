module paramsparser

import freeflowuniverse.crystallib.core.texttools.regext
import freeflowuniverse.crystallib.core.texttools

// find parts of text in PARAM values which are of form {NAME}, and replace those .
// .
// will walk over all elements of the params, and then replace all the values .
// .
// NAME is as follows: .
//   Uppercase letters: A-Z .
//   Lowercase letters: a-z .
//   Digits: 0-9 .
//   Underscore: _ .
// .
// the NAME is key of the map, the val of the map is what we replace with
pub fn (mut params Params) replace(args map[string]string) {
	for mut p in params.params {
		for i in regext.find_simple_vars(p.value) {
			i2 := texttools.name_fix(i)
			if i2 in args {
				println('${i} -> ${args[i2]}')
				p.value = p.value.replace('{${i}}', args[i2])
			}
		}
	}
}

pub fn (mut params Params) replace_from_params(params_ Params) {
	p := params_.get_map()
	params.replace(p)
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
