module publisher_config

// websites are under $ipaddr/$shortname
// wiki are under $ipaddr/info/$shortname
// JSON REPRESENTATION:
// {
//     "googletagmanager.js": "https: //www.googletagmanager.com/gtag/js?id=UA-100065546-4",
//     "cookie-consent.js": "https: //www.freeprivacypolicy.com/public/cookie-consent/3.1.0/cookie-consent.js",
//     "theme-simple.css": "https: //cdn.jsdelivr.net/npm/docsify-themeable@0/dist/css/theme-simple.css",
//     "simple-lightbox.min.css": "https: //cdnjs.cloudflare.com/ajax/libs/simplelightbox/2.1.5/simple-lightbox.min.css",
//     "d3.min.js": "https: //unpkg.com/d3@3/d3.min.js",
//     "d3-flextree.js": "https: //unpkg.com/markmap@0.6.0/lib/d3-flextree.js",
//     "view.mindmap.js": "https: //unpkg.com/markmap@0.6.0/lib/view.mindmap.js",
//     "docsify.min.js": "https: //cdn.jsdelivr.net/npm/docsify/lib/docsify.min.js",
//     "docsify-example-panels.js": "https: //cdn.jsdelivr.net/npm/docsify-example-panels",
//     "prism-bash.min.js": "https: //cdn.jsdelivr.net/npm/prismjs/components/prism-bash.min.js",
//     "prism-python.min.js": "https: //cdn.jsdelivr.net/npm/prismjs/components/prism-python.min.js",
//     "search.min.js": "https: //unpkg.com/docsify/lib/plugins/search.min.js",
//     "docsify-remote-markdown.min.js": "https: //unpkg.com/docsify-remote-markdown/dist/docsify-remote-markdown.min.js",
//     "docsify-tabs@1.js": "https: //cdn.jsdelivr.net/npm/docsify-tabs@1",
//     "docsify-themeable@0.js": "https: //cdn.jsdelivr.net/npm/docsify-themeable@0",
//     "docsify-sidebar-collapse.min.js": "https: //unpkg.com/docsify-sidebar-collapse/dist/docsify-sidebar-collapse.min.js",
//     "zoom-image.min.js": "https: //cdn.jsdelivr.net/npm/docsify/lib/plugins/zoom-image.min.js",
//     "docsify-copy-code.js": "https: //cdn.jsdelivr.net/npm/docsify-copy-code",
//     "docsify-glossary.min.js": "unpkg.com/docsify-glossary/dist/docsify-glossary.min.js",
//     "simple-lightbox.min.js": "https: //cdnjs.cloudflare.com/ajax/libs/simplelightbox/2.1.5/simple-lightbox.min.js",
//     "mermaid.min.js": "https: //unpkg.com/mermaid@8.9.2/dist/mermaid.min.js",
//     "docsify-mermaid.js": "https: //unpkg.com/docsify-mermaid@latest/dist/docsify-mermaid.js",
//     "docsify-mindmap.min.js": "https: //unpkg.com/docsify-mindmap/dist/docsify-mindmap.min.js",
//     "docsify-charty.min.js": "https: //unpkg.com/@markbattistella/docsify-charty@1.0.5",
//     "docsify-charty.min.css": "https: //unpkg.com/@markbattistella/docsify-charty@1.0.5/dist/docsify-charty.min.css",
//     "charty-custom-style.css": "https: //raw.githubusercontent.com/markbattistella/docsify-charty/fa755c3e058ba1110fc6586a50207626d552b88f/docs/site/style.min.css"
// }
fn staticfiles_config(mut c ConfigRoot) {
	c.staticfiles = map{
		'googletagmanager.js':             'https://www.googletagmanager.com/gtag/js?id=UA-100065546-4'
		'cookie-consent.js':               'https://www.freeprivacypolicy.com/public/cookie-consent/3.1.0/cookie-consent.js'
		'theme-simple.css':                'https://cdn.jsdelivr.net/npm/docsify-themeable@0/dist/css/theme-simple.css'
		'simple-lightbox.min.css':         'https://cdnjs.cloudflare.com/ajax/libs/simplelightbox/2.1.5/simple-lightbox.min.css'
		'd3.min.js':                       'https://unpkg.com/d3@3/d3.min.js'
		'd3-flextree.js':                  'https://unpkg.com/markmap@0.6.0/lib/d3-flextree.js'
		'view.mindmap.js':                 'https://unpkg.com/markmap@0.6.0/lib/view.mindmap.js'
		'docsify.min.js':                  'https://cdn.jsdelivr.net/npm/docsify/lib/docsify.min.js'
		'docsify-example-panels.js':       'https://cdn.jsdelivr.net/npm/docsify-example-panels'
		'prism-bash.min.js':               'https://cdn.jsdelivr.net/npm/prismjs/components/prism-bash.min.js'
		'prism-python.min.js':             'https://cdn.jsdelivr.net/npm/prismjs/components/prism-python.min.js'
		'search.min.js':                   'https://unpkg.com/docsify/lib/plugins/search.min.js'
		'docsify-remote-markdown.min.js':  'https://unpkg.com/docsify-remote-markdown/dist/docsify-remote-markdown.min.js'
		'docsify-tabs@1.js':               'https://cdn.jsdelivr.net/npm/docsify-tabs@1'
		'docsify-themeable@0.js':          'https://cdn.jsdelivr.net/npm/docsify-themeable@0'
		'docsify-sidebar-collapse.min.js': 'https://unpkg.com/docsify-sidebar-collapse/dist/docsify-sidebar-collapse.min.js'
		'zoom-image.min.js':               'https://cdn.jsdelivr.net/npm/docsify/lib/plugins/zoom-image.min.js'
		'docsify-copy-code.js':            'https://cdn.jsdelivr.net/npm/docsify-copy-code'
		'docsify-glossary.min.js':         'unpkg.com/docsify-glossary/dist/docsify-glossary.min.js'
		'simple-lightbox.min.js':          'https://cdnjs.cloudflare.com/ajax/libs/simplelightbox/2.1.5/simple-lightbox.min.js'
		'mermaid.min.js':                  'https://unpkg.com/mermaid@8.9.2/dist/mermaid.min.js'
		'docsify-mermaid.js':              'https://unpkg.com/docsify-mermaid@latest/dist/docsify-mermaid.js'
		'docsify-mindmap.min.js':          'https://unpkg.com/docsify-mindmap/dist/docsify-mindmap.min.js'
		'docsify-charty.min.js':           'https://unpkg.com/@markbattistella/docsify-charty@1.0.5'
		'docsify-charty.min.css':          'https://unpkg.com/@markbattistella/docsify-charty@1.0.5/dist/docsify-charty.min.css'
		'charty-custom-style.css':         'https://raw.githubusercontent.com/markbattistella/docsify-charty/fa755c3e058ba1110fc6586a50207626d552b88f/docs/site/style.min.css'
	}
}
