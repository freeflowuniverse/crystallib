module params

fn test_macro_args() {
	mut text := "arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok'"
	mut params := parse(text) or { panic(err) }

	assert params.filter_match(include: ['description:*see*'])!

	assert params.filter_match(include: ['priority:incredible'])!

	assert params.filter_match(include: ['arg2'])!

	c := params.filter_match(include: ['arg'])!
	assert c == false

	d := params.filter_match(include: ['a*rg'])!
	assert d == false

	e := params.filter_match(include: ['arg*'])!
	assert e

	f := params.filter_match(include: ['arg*'])!
	assert f

	f_ := params.filter_match(include: ['arg1+arg2'])!
	assert f_

	g := params.filter_match(include: ['arg1+arg3'])!
	assert g==false

	// NEXT: do include and excluse and more than one as well
}
