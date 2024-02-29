module markdownparser

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.data.markdownparser.elements

const text = '
# Farmerbot

Welcome to the farmerbot. 
### Content: 
- [Introduction](introduction.md)
- [About us](aboutus.md)
  - [Our Goals & Strategy](mission.md)
  - [What we have done so far](sofar.md)
  - [Our team](team.md)
- [About Dams](aboutdams.md)
  - [The Hydro Dam Gold Rush](damgoldrush.md)
- [About Rivers](aboutrivers.md)
- [Dams in the Balkans](damsbalkans.md)
  - [Why the Balkans?](whybalkans.md)
  - [Community Uprising against the Dams in the Balkans](community.md)
  - [Why Montenegro?](whymontenegro.md)
  - [Case Study: Komarnica Dam](komarnicadam.md)
  - [Current Hydro Dam Mitigation Challenges](mitigation.md)
  - test
  - [Climate Vulnerability](climatevulnerability.md)



'

fn test_wiki_headers_paragraphs() {
	mut docs := new(content: markdownparser.text)!
	println(docs.treeview())
	println(docs.markdown()!)

	// if true{
	// 	panic("s")
	// }
}
