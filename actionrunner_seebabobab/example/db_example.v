module main

import freeflowuniverse.crystallib.actionrunner
import freeflowuniverse.crystallib.params

const domain="mydomain"

fn do() ! {
	mut db:=actionrunner.new_db()!

	mut text := "
		id:a1 name6:aaaaa
		name:'need to do something 1' 
		description:
			## markdown works in it

			description can be multiline
			lets see what happens

			- a
			- something else

			### subtitle

			```python
			#even code block in the other block, crazy parsing for sure
			def test():
				print()
			```

		name2:   test
		name3: hi name10:'this is with space'  name11:aaa11

		#some comment

		name4: 'aaa'

		//somecomment
		name5:   'aab' 
	"

	params := params.parse(text) or { panic(err) }

	model:="test"


	db.set(domain,model,3,params)!
	db.set(domain,model,4,params)!
	params2:=db.get(domain,model,3)!


	db.key_set(domain,model,"name.myname",3)!
	db.key_set(domain,model,"name.myname2",4)!
	id:=db.key_get(domain,model,"name.myname")!
	assert id==3

	ks:=db.keys_get(domain,model, "name.")!
	assert ks==[u32(3), u32(4)]

	db.delete_model(domain,model)!
	ks2:=db.keys_get(domain,model, "name.")!
	assert ks2==[]

	// println(params2)

}

fn main() {
	do() or { panic(err) }
}
