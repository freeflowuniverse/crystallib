module heroweb

import freeflowuniverse.crystallib.webserver.auth.authentication.email {StatelessAuthenticator}
import veb

pub struct WebDB {
pub mut:
	authenticator StatelessAuthenticator
	users        map[u16]&User
	groups       map[string]&Group
	acls         map[string]&ACL
	infopointers map[string]&InfoPointer
}

pub struct Context {
	veb.Context
pub mut:
	// In the context struct we store data that could be different
	// for each request. Like a User struct or a session id
	user_id       u16
	session_id string
}


pub struct NavItem {
pub mut:
    href string
    text string
    class_name ?string
}

pub struct Navbar {
pub mut:
    brand NavItem
    items []NavItem
}

pub struct MarkdownContent {
pub mut:
    nav string
    content string
    title string
}

pub struct Doc {
pub mut:
    navbar Navbar
    markdown MarkdownContent
    title string
}

fn model_web_example() Doc {
    
    example_main:=$tmpl("templates/example_main.md")
    example_nav:=$tmpl("templates/example_nav.md")

    navbar := Navbar{
        brand: NavItem{href: '#', text: 'MyWebsite', class_name: 'brand'},
        items: [
            NavItem{href: '#home', text: 'Home'},
            NavItem{href: '#about', text: 'About'},
            NavItem{href: '#services', text: 'Services'},
            NavItem{href: '#contact', text: 'Contact'}
        ]
    }

    markdown_content := MarkdownContent{nav: example_nav, content: example_main, title: 'MyDoc'}

    return Doc{navbar: navbar, markdown: markdown_content, title: 'An Example Index Page'}
}
