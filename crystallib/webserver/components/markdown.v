module components

import freeflowuniverse.crystallib.data.markdownparser.elements

pub struct Markdown {
pub:
    doc elements.Doc
}

pub fn (md Markdown) html() string {
    return md.doc.html() or {''}
}