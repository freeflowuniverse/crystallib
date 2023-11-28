module markdownparser

import freeflowuniverse.crystallib.data.paramsparser { Param, Params }

import freeflowuniverse.crystallib.core.texttools

fn test_action1() {


	mut c:='
	# header

	some text

	!!farmerbot.nodemanager_define
		id:15
		twinid:20
		has_public_ip:yes
		has_public_config:1

	a line

	```
	//in codeblock
	!!farmerbot.nodemanager_delete
		id:16	
	```

	another line

	```js
	!!farmerbot.nodemanager_start id:17
	```
	

	'

	c=texttools.dedent(c)

	mut doc := new(content: c) or {panic(err)}

	println(doc.treeview())
	println(doc)

	if true{panic("sdsds")}


}
