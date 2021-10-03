module serializers

pub fn map_string_string_to_text(toserialize map[string]string) string {
	mut out := []string{}
	for key,val in toserialize{
		out << "$key = $val"
	}
	mut outtext := out.join("\n")
	outtext += "\n"
	return outtext
}

pub fn text_to_map_string_string(todeserialize string) map[string]string  {
	mut res := map[string]string{}
	for line in todeserialize.split("\n"){
		if line.contains("="){
			key:=line.split("=")[0].trim(" ")
			val:=line.split("=")[1].trim(" ")
			res[key] = val
		}
	}	
	return res
}


