module texttools

enum SplitState{
	start
	string
}

// split strings in intelligent ways, taking into consideration '"`
// ```
// r0:=texttools.split_smart("'root'   304   0.0  0.0 408185328   1360   ??  S    16Dec23   0:34.06 /usr/sbin/distnoted\n \n")
// assert ['root', '304', '0.0', '0.0', '408185328', '1360', '??', 'S', '16Dec23', '0:34.06', '/usr/sbin/distnoted']==r0
// ```
pub fn split_smart(t string,delimiter_ string) []string {
	mut st := SplitState.start
	mut last:=[]string{}
	mut result:=[]string{}
	mut delimiter:=delimiter_
	if delimiter.len==0{
		 delimiter= ",| "
	}
	for c in t.trim_space().split(""){
		// println("$c ${st} ${last}")
		if st==.start && "`'\"".contains(c){
			//means we are at start if quoted string
			st = .string
			continue
		}
		if st==.string && "`'\"".contains(c){
			//means we are at end of quoted string
			st = .start
			result<<last.join("").trim_space()
			last=[]string{}
			continue
		}		
		if st==.string{
			last<<c
			continue
		}
		if delimiter.contains(c){
			if last.len>0{
				result<<last.join("").trim_space()
			}
			last=[]string{}
			continue			
		}
		last<<c
	}
	if last.len>0{
		result<<last.join("").trim_space()
	}
	return result
}

