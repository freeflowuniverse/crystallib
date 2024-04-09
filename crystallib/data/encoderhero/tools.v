module heroencoder

//if at top of struct we have: @[name:"teststruct " ; params] .
//will return {'name': 'teststruct', 'params': ''}
fn attrs_get_reflection(mytype reflection.Type) map[string]string{
	if mytype.sym.info is reflection.Struct{
		return attrs_get(mytype.sym.info.attrs)
	}	
	return map[string]string{}
}

//will return {'name': 'teststruct', 'params': ''}
fn attrs_get(attrs []string) map[string]string{
	mut out:=map[string]string{}
	for i in attrs{
		if i.contains("="){
			kv:=i.split("=")
			out[kv[0].trim_space().to_lower()]=kv[1].trim_space().to_lower()
		}else{
			out[i.trim_space().to_lower()]=""
		}
	}
	return out
}
