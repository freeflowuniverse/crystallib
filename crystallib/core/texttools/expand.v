module texttools


// texttools.expand('|', 20, ' ')
pub fn expand(txt_ string, l int, expand_with string) string {
	mut txt:=txt_
	for _ in 0..l{
		txt+=expand_with
	}
	return txt
}