module texttools



fn test_tokens() {
	mut text := '
	these; Are Some ramdom words!
	blue lagoon
	Blue lagoon
	blue_lagoon
	blue_Lagoon
	lagoon
	;bluelagoon

	'
	r:=tokenize(text)
	// println(r)

	r2 := texttools.TokenizerResult{
    items: [texttools.TokenizerItem{
        toreplace: 'these'
        matchstring: 'these'
    }, texttools.TokenizerItem{
        toreplace: 'Are'
        matchstring: 'are'
    }, texttools.TokenizerItem{
        toreplace: 'Some'
        matchstring: 'some'
    }, texttools.TokenizerItem{
        toreplace: 'ramdom'
        matchstring: 'ramdom'
    }, texttools.TokenizerItem{
        toreplace: 'words'
        matchstring: 'words'
    }, texttools.TokenizerItem{
        toreplace: 'blue'
        matchstring: 'blue'
    }, texttools.TokenizerItem{
        toreplace: 'lagoon'
        matchstring: 'lagoon'
    }, texttools.TokenizerItem{
        toreplace: 'Blue'
        matchstring: 'blue'
    }, texttools.TokenizerItem{
        toreplace: 'blue_lagoon'
        matchstring: 'bluelagoon'
    }, texttools.TokenizerItem{
        toreplace: 'blue_Lagoon'
        matchstring: 'bluelagoon'
    }, texttools.TokenizerItem{
        toreplace: 'bluelagoon'
        matchstring: 'bluelagoon'
    }]}
	assert r==r2
}

fn test_tokens2() {

	mut text := '
	these; Are Some ramdom words!
	blue lagoon
	Blue lagoon
	red_dragon
	reddragon
	blue_lagoon
	blue_Lagoon
	lagoon
	;bluelagoon

	'

	mut ri := regex_instructions_new(['bluelagoon:reddragon:ThreeFold']) or {
		panic(err)
	}

	mut text_out2 := ri.replace(text) or { panic(err) }

	compare := '
	these; Are Some ramdom words!
	blue lagoon
	Blue lagoon
	ThreeFold
	ThreeFold
	ThreeFold
	ThreeFold
	lagoon
	;ThreeFold

	'

	println(text_out2)

	assert dedent(text_out2).trim(' \n') == dedent(compare).trim(' \n')


}