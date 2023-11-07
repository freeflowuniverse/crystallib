import freeflowuniverse.crystallib.web.components
import vweb
import os

struct App {
	vweb.Context
}

pub fn (mut app App) index() vweb.Result {
	title := 'Flowrift'
	view := components.Shell{
		navbar: components.Navbar{
			menu: components.Menu{
				logo: 'Flowrift'
				items: [
					components.MenuItem{
						label: 'Home'
						route: '/'
					},
					components.MenuItem{
						label: 'Features'
						route: '#'
					},
					components.MenuItem{
						label: 'Pricing'
						route: '#'
					},
					components.MenuItem{
						label: 'About'
						route: '#'
					},
				]
			}
		}
		// page: components.HomePage{
		// hero: flowrift.Hero{}
		// team: flowrift.Team{}
		// }
		// footer: flowrift.Footer{}
	}
	return $vweb.html()
}

pub fn main() {
	dir := os.dir(@FILE)
	os.chdir(dir)!
	os.execute('tailwindcss -i ${dir}/index.css -o ${dir}/static/css/index.css --minify')

	mut app := &App{}
	app.mount_static_folder_at('${dir}/static', '/static')
	vweb.run[App](app, 8080)
}
