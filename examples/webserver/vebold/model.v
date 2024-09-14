from dataclasses import dataclass
from typing import List, Optional


@dataclass
class NavItem:
    href: str
    text: str
    class_name: Optional[str] = None


@dataclass
class Navbar:
    brand: NavItem
    items: List[NavItem]


@dataclass
class MarkdownContent:
    nav: str
    content: str
    title: str = 'MyDoc'


@dataclass
class Doc:
    navbar: Navbar
    markdown: MarkdownContent
    title: str = 'An Example Index Page'


def example() -> Doc:
    import os

    base_dir = os.path.dirname(__file__)
    templates_dir = os.path.join(base_dir, 'templates')

    with open(os.path.join(templates_dir, 'example_main.md'), 'r') as f:
        example_main = f.read()

    with open(os.path.join(templates_dir, 'example_nav.md'), 'r') as f:
        example_nav = f.read()

    navbar = Navbar(
        brand=NavItem(href='#', text='MyWebsite', class_name='brand'),
        items=[
            NavItem(href='#home', text='Home'),
            NavItem(href='#about', text='About'),
            NavItem(href='#services', text='Services'),
            NavItem(href='#contact', text='Contact'),
        ],
    )

    markdown_content = MarkdownContent(nav=example_nav, content=example_main)

    return Doc(navbar=navbar, markdown=markdown_content)
