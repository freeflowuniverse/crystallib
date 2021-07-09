module publisher_config

// {
//   "name": "incachain",
//   "cat": 0,
//   "descr": "",
//   "depends": []
// }
pub struct SiteConfigLocal {
pub mut:
	name       string
	cat        SiteCat
	descr      string
	dependencies []SiteDependency
}



pub struct SiteDependency {
pub mut:
	url       string
	path        string
	branch      string
}



