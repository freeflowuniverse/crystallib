module components

import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.data.markdownparser.elements
import freeflowuniverse.crystallib.webserver.auth.authentication.email {StatelessAuthenticator}
import veb


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

pub struct View {
pub mut:
    navbar Navbar
    content elements.Doc
    markdown MarkdownContent
    title string
}

pub fn (view View) html() string {
    return $tmpl('./templates/view.html')
}

fn model_web_example() View {
    
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

    markdown_content := MarkdownContent{nav: example_nav, content: example_main, title: 'MyView'}

    return View{navbar: navbar, markdown: markdown_content, title: 'An Example Index Page'}
}
