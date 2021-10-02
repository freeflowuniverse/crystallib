module builder



pub fn (mut node Node) done_set(key string, val string)? {
	node.done[key] = val
	node.done_save()?
}

pub fn (mut node Node) done_get(key string) ?string {
	if ! (key in node.done){
		return none
	}
	return node.done[key]
}

pub fn (mut node Node) done_exists(key string) bool {
	return (key in node.done)
}


pub fn (mut node Node) done_save()?{
	mut out := []string{}
	for key,val in node.done{
		out << "$key = $val"
	}
	mut outtext := out.join("\n")
	outtext += "\n"
	node.db.set("done",outtext)?	
}

pub fn (mut node Node) done_load()?{
	if node.db.exists("done"){
		println("exists")
		res := node.db.get("done")?
		for line in res.split("\n"){
			if line.contains("="){
				key:=line.split("=")[0].trim(" ")
				val:=line.split("=")[1].trim(" ")
				node.done[key] = val
			}
		}	
	}
}


pub fn (mut node Node) done_reset()? {
	node.done = map[string]string{}
	node.db.delete("done")?
}


