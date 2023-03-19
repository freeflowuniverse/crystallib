module tfgrid

//TODO: describe how format is of the params and fill in default
//TODO: what does add_access mean?
pub struct Network {
pub:
	name       string 
	ip_range   string = "" //TODO, format?
	add_access bool   [json: 'addAccess'] //TODO: what does this mean?
}

