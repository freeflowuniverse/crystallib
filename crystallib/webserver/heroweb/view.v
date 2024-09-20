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

