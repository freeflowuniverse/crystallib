module publisher_config

// as it is used on filesystem

pub struct SiteConfigRaw {
pub mut:
	name     string
	reponame string
	prefix   string // prefix as will be used on web, is optional
	// the site config is known by git_url or by fs_path
	git_url    string
	fs_path    string // path directly in the git repo or absolute on filesystem
	pull       bool   // if set will pull but not reset
	reset      bool   // if set will reset & pull, reset means remove changes
	cat        string
	path       string // path where the site is, the result of git operation or fs_path
	domains    []string
	descr      string
	acl        []SiteACE // access control list
	trackingid string    // Matomo/Analytics
	opengraph  OpenGraph
	// depends []SiteDependency
	// configroot &ConfigRoot
}

// pub struct SiteDependencyRaw {
// pub mut:
// 	git_url       string
// 	path        string  //path in the git repo as defined by the git_url
// 	fs_path	  string    //path as on fs, can be local to the location of this config file
// 	branch      string
// }

pub struct SiteACE {
pub mut:
	groups  []string
	users   []string
	rights  string = 'R' // default R today
	secrets []string // is list of secrets in stead of threefold connect which can give access
}
