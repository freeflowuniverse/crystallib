#!/usr/bin/env v -w -cg -enable-globals run

// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import log
import freeflowuniverse.crystallib.data.markdownparser
import os


console.print_header("Print markdown in treeview.")
println("")
// mut session := play.session_new(
// 	context_name: "test"
// 	interactive: true
// )!

//get path local to the current script
path_my_content := '${os.dir(@FILE)}/content'


mut doc1 := markdownparser.new(
	// path: '${path_my_content}/test_para.md'
	path: '${path_my_content}/test.md'
)!
content1 := doc1.markdown()

println(doc1.treeview())


console.print_header("Markdown output:")
println("")
println(content1)


console.print_header("Actions:")
println("")
println(doc1.actions(actor:"myactor",name:"myname"))

console.print_header("Action Pointers:")
println("")
for a in doc1.action_pointers(actor:"myactor",name:"myname"){	
	doc1.content_set(a.element_id,"> THIS IS WHAT WE FILL IN FROM ACTOR")
	println(a)
}

console.print_header("Markdown output after macro's:")
println("")
content2 := doc1.treeview()
println(content2)

