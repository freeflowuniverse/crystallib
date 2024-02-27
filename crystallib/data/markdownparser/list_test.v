module markdownparser


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
   - 1,2,3 and 4 whitespaces have the same indentation, so this line should have the same indentation as the previous line
    - this has the same indentation as the previous one 
     - this is at an indentation level deeper than the previous one

1. first ordered list item
2. second orderd list items


'

fn test_wiki_headers_paragraphs() {
	mut docs := new(content: markdownparser.text)!
	println(docs.treeview())
	println(docs.markdown()!)

	// if true{
	// 	panic("s")
	// }
}
