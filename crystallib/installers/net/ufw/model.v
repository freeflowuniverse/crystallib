module ufw


pub struct UFWData {
pub mut:
	active bool
	rules  []Rule
}


pub struct Rule {
pub mut: 
	ipv6 bool
	to     string
	from   string
	tcp bool
	udp bool
	allow  bool //if not then is denied
}
