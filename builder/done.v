module builder

import serializers


pub fn (mut node Node) done_set(key string, val string)? {
	if key in node.done{
		if node.done[key] == val{
			return
		}
	}
	node.done[key] = val
	node.done_save()?
}

pub fn (mut node Node) done_get(key string) ?string {
	if ! (key in node.done){
		return none
	}
	return node.done[key]
}

//will return empty string if it doesnt exist
pub fn (mut node Node) done_get_str(key string) string {
	if ! (key in node.done){
		return ""
	}
	return node.done[key]
}

//will return 0 if it doesnt exist
pub fn (mut node Node) done_get_int(key string) int {
	if ! (key in node.done){
		return 0
	}
	return node.done[key].int()
}



pub fn (mut node Node) done_exists(key string) bool {
	// println(node.done)
	// println(key)
	return (key in node.done)
}

pub fn (mut node Node) done_print() {
	println("   DONE: $node.name ")
	for key,val in node.done{		
		println("   . $key = $val")
	}
}


pub fn (mut node Node) done_save()?{
	outtext := serializers.map_string_string_to_text(node.done)
	node.db.set("done",outtext)?	
	node.cache.set("node_done",outtext,600)?	
	println(" . $node.name done set: \n$outtext")
}

pub fn (mut node Node) done_load()?{
	if node.db.exists("done"){
		res := node.db.get("done")?
		for line in res.split("\n"){
			if line.contains("="){
				key:=line.split("=")[0].trim(" ")
				val:=line.split("=")[1].trim(" ")
				// println(" . $node.name done load: $key=$val")
				node.done[key] = val
			}
		}	
		node.cache.set("node_done",res,600)?	
	}
}


pub fn (mut node Node) done_reset()? {
	node.done = map[string]string{}
	node.db.delete("done")?
	println(" . $node.name done delete")
}


