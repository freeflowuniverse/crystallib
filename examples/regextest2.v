import regex

fn main() {

	// query := '\[(.*)\]\( *(\w*\:*\w*) *\)'
	// query := '\[(.*)\]\( *(\w*\:*\w*) *\)'

	// query := r'this (\w+) a'

	// query := r'\[.*\]\( *\w*\:*\w+ *\)'
	// query := '\[.*\]\( *\w*\:*\w+ *\)'

	mut text := "[ an s. s! ]( wi4ki:something )
	[ AN s. s! ]( wi4_ki:some_thing )
	[ an s. s! ](wiki:something)
	[ an s. _s! ](something)dd
	* [The Threefold Story](tf_thestory.md)
	d [ an s. s! ](something ) d
	[  more text ]( something ) s [ something b ](something)dd

	"



	// text = "[  more text ]( something ) s [ something b ](something)dd"

  //check the regex on https://regex101.com/r/HdYya8/1/

	// query := r'(\[[a-z\.\! ]*\]\( *\w*\:*\w* *\))*'
	// query := r'(\[[a-z\.\! ]*\]\( *\w*\:*\w* *\))'
	// regex := '.*'

	// mut re := regex.new()
	// re.compile_opt(query) or { panic(err) }

	// re.debug = 1 // set debug on at minimum level
	// println('#query parsed: $re.get_query()')
	// re.debug = 0

	// println(re.find_all(text))

	// re.match_string(text)

	// println("nr groups: ${re.groups.len}")

	// for g in re.groups {
	// 	println(g)
	// }

	// println(re.groups)
	// println(re.groups[1])


	// for g in re.get_group_list(){
	// 	println(g)
	// }

	query := r'(\[[\w_\.\! ]*\]\( *[\w_]*\:*[\w_\.]* *\))'

	mut re := regex.new()
	re.compile_opt(query) or { panic(err) }	

	mut gi := 0
	all := re.find_all(text)
	for gi < all.len {
		println(':${text[all[gi]..all[gi + 1]]}:')
		gi += 2
	}
	println('')


}