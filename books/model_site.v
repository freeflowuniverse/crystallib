module books
import path as pathlib

enum SiteType{
	book
	wiki
	web
}

[heap]
struct Site {
pub:
	name string
	sites &Sites [str: skip] //pointer to sites
	sitetype SiteType
pub mut:
	pages map[string]Page
	files map[string]File
	path pathlib.Path
}



//walk over one specific site, find all files and pages
pub fn (mut site Site) scan()? {
	site.scan_internal(site.path)?

}


fn (mut site Site) scan_internal(path pathlib.Path)? {

	panic("sitescan")


}
