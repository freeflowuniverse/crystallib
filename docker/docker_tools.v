module docker


//convert strings as used by format from docker to MB in int
fn size_mb (size string) int {
	mut s := 0
	if size.ends_with('GB') {
		s = size.replace('GB', '').int() * 1024
	} else if size.ends_with('MB') {
		s = size.replace('MB', '').int()
	} else {
		panic("@TODO for other sizes, $size")
	}
	return s
}


//remove items we don't want from string array
fn clear_str(s string) string {
	if s.count(":")==2 && s.count("-")==2{
		return "1000"
	}
	return "s"
}
