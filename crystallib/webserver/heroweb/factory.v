module heroweb

import veb
import os
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.clients.mailclient
import freeflowuniverse.crystallib.webserver.auth.jwt
import freeflowuniverse.crystallib.webserver.log
import db.sqlite

pub fn (app &App) index(mut ctx Context) veb.Result {
	doc := Doc{
        navbar: Navbar{
            brand: NavItem{
                href: "/",
                text: "OurWorld",
                class_name: "brand"
            },
            items: [
                NavItem{
                    href: "/about",
                    text: "About Us",
                    class_name: "nav-item"
                },
                NavItem{
                    href: "/projects",
                    text: "Projects",
                    class_name: "nav-item"
                },
                NavItem{
                    href: "/contact",
                    text: "Contact",
                    class_name: "nav-item"
                }
            ]
        },
        content: markdownparser.new(path: '${os.dir(@FILE)}/content/index.md') or {
			return ctx.server_error(err.str())
		}
    }
	return ctx.html($tmpl('./templates/index.html'))
}

pub fn (app &App) dashboard(mut ctx Context) veb.Result {
	user := app.db.users[ctx.user_id]
	return ctx.html($tmpl('./templates/dashboard.html'))
}

//the path is pointing to the instructions
pub fn new(path string) !&App {
	mut app := &App{
		db: WebDB{
		logger: log.new(
			backend: log.new_backend(
				db: 
					sqlite.connect('${os.dir(@FILE)}/logger.sqlite')!
				)!
			)!
		}
	}

	// lets mount the middlewares the app should use
	app.mount_middlewares()

	app.mount_static_folder_at('${os.home_dir()}/code/github/freeflowuniverse/crystallib/crystallib/webserver/heroweb/static','/static')!


	// lets play the heroscripts to setup the app
	app.play(path)!

	// lets run the heroscripts
	app.run_infopointer_heroscripts()!

	return app
}

fn (mut app App) mount_middlewares() {
	app.use(handler: app.set_user)

	// must be logged in to view views
	app.route_use('/view', handler: app.is_logged_in)
	app.route_use('/view/:path...', handler: app.is_logged_in)

	// must be authorized to fetch infopointers and pointed assets
	app.route_use('/infopointer/:path...', handler: app.is_authorized)
	app.route_use('/assets/:path...', handler: app.is_authorized)
}

fn (mut app App) play(path string) ! {
	mut plbook := playbook.new(path: path)!

	//lets make sure the authentication & authorization is filled in
	app.db.play_authentication(mut plbook)!
	app.db.play_authorization(mut plbook)!
	//now lets add the infopointers
	app.db.play_infopointers(mut plbook)!
}

fn (mut app App) run_infopointer_heroscripts() ! {
	app.static_mime_types['.mmd'] = 'txt/plain'
	for key, ptr in app.db.infopointers{
		app.db.infopointer_run(key)!
		if ptr.path_content == '' {
			continue
		}

		mut asset := pathlib.get(ptr.path_content)
		if !asset.exists() {
			return error('Asset ${ptr.name} does not exist on path ${ptr.path_content}')
		}
		if asset.is_file() {
			app.serve_static('/assets/${ptr.name}.${asset.extension()}', asset.path)!
		} else if asset.is_dir() {
			app.mount_static_folder_at(asset.path, '/assets/${ptr.name}')!
		} else {
			return error('unsupported path ${asset}')
		}
	}
}