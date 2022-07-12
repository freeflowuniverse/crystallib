	
module publisher_web
	
//specicif for threefold, see which sitenames need to be changed
fn threefold_sitename_modifier(sitename string) string{
	if sitename == 'tfgrid' {
		sitename = 'threefold'
	}
	if sitename == 'tokens' {
		sitename = 'threefold'
	}
	if sitename == 'cloud' {
		sitename = 'threefold'
	}
	if sitename == 'internet4' {
		sitename = 'threefold'
	}
	return sitename
}
