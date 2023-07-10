module publisher_core

import os
import publisher_config

fn template_wiki_root(reponame string, repourl string, trackingid string, opengraph publisher_config.OpenGraph) ?string {
	mut cfg := publisher_config.get()?
	mut p := os.join_path(cfg.publish.paths.base, 'static')
	mut crispwebsiteid := '1a5a5241-91cb-4a41-8323-5ba5ec574da0'
	if reponame == 'twin' {
		crispwebsiteid = 'fa9a7744-5454-4e83-99ae-9ef342d3bff4'
	}

	p = '.$p'

	index_wiki := r'
    <!DOCTYPE html>
    <html>
    <head>
      <script type="text/javascript" src="cookie-consent.js"></script> 
      <script type="text/javascript"> document.addEventListener("DOMContentLoaded", function () { cookieconsent.run({"notice_banner_type":"headline","consent_type":"express","palette":"light","language":"en","website_name":"https://wiki.threefold.io/","cookies_policy_url":"https://wiki.threefold.io/#/privacypolicy"}); }); </script>
      <script type="text/plain" cookie-consent="functionality">window.$crisp=[];window.CRISP_WEBSITE_ID="@crispwebsiteid";(function(){d=document;s=d.createElement("script");s.src="https://client.crisp.chat/l.js";s.async=1;d.getElementsByTagName("head")[0].appendChild(s);})();</script>    
      <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <meta charset="UTF-8">
      <meta property="og:url"                content="@og_url" />
      <meta property="og:type"               content="@og_type" />
      <meta property="og:title"              content="@og_title" />
      <meta property="og:description"        content="@og_description" />
      <meta property="og:image"              content="@og_image" />
      <meta property="og:image:width" content="@og_image_width" />
      <meta property="og:image:height" content="@og_image_height" />
      
      <link rel="stylesheet" href="theme-simple.css">

    <style>
        :root {
            --graph-size: 750 !important;
        }
        .markdown-section {
            max-width: 60em !important;  
            padding-left: 0 !important;
            padding-right: 0 !important;
        }
        .gallery {
            display: flex;
            flex-wrap: wrap;
        }
        .gallery > a {
            flex: 0 0 33.333334%;
            max-width: 33.333334%;
            overflow: hidden;
        }
        .gallery > a:hover > img {
            transform: scale(1.2);
        }
        .gallery > a > img {
            height: 100%;
            width: 100%;
            transition: transform 0.3s ease-in;
        }
    </style>
    </head>
    <body>
    <!-- Matomo -->
        <script type="text/javascript">
        var _paq = window._paq = window._paq || [];
        /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
        _paq.push(["trackPageView"]);
        _paq.push(["enableLinkTracking"]);
    
        window.addEventListener("hashchange", function() {
            console.log(window.location.hash.substr(2))
            _paq.push(["trackPageView"]);
            _paq.push(["enableLinkTracking"]);
            _paq.push(["setDocumentTitle", window.location.hash.substr(2)]);
             _paq.push(["setCustomUrl", "/" + window.location.hash.substr(2)]);
              
        });

        (function() {
            var u="//analytics.threefold.io/";
            _paq.push(["setTrackerUrl", u+"matomo.php"]);
            _paq.push(["setSiteId", "@trackingid"]);
             _paq.push(["setCustomUrl", "/" + window.location.hash.substr(2)]);
            var d=document, g=d.createElement("script"), s=d.getElementsByTagName("script")[0];
            g.type="text/javascript"; g.async=true; g.src=u+"matomo.js"; s.parentNode.insertBefore(g,s);
        })();
        </script>
    <!-- End Matomo Code -->

    <!-- markmap is based on d3, so must load those files first. -->
     <script src="d3.min.js"></script>
    <script src="d3-flextree.js"></script>
    <script src="view.mindmap.js"></script>
    <script src="tf-tracker.js"></script>
    <script src="pdf.min.js"></script>
    <script src="pdf.worker.min.js"></script>
    <script src="tf-pdf.js"></script>

      <div id="app"></div>
      <script>
        window.$docsify = {
            name: "@reponame",
            repo: "@repourl",
            loadSidebar: true,
            loadNavbar: true,
            auto2top: true,
            search: "auto",
            remoteMarkdown: {
              tag: "remoteMarkdownUrl",
            },
            subMaxLevel: 0,
            themeable: {
                readyTransition : true, // default
                responsiveTables: true  // default
            },
            markdown: {
                renderer: {
                    code: function (code, lang) {
                        if (lang === "pdf") {
                            return `<embed src="https://drive.google.com/viewerng/viewer?embedded=true&url="` + code +  `width="100%" height="800">`
                        }
                        if (lang === "gallery") {
                            let lines = code.split("\\n");
                            let images = "";
                            for (let line of lines) {
                                if (line) {
                                    let parts = line.split("=");
                                    if (parts.length == 2){
                                        let name = parts[0].trim();
                                        let url = parts[1].trim()
                                        images += `<a href=${url} class="big">
                                                    <img src=${url} alt="${name}" title="${name}">
                                                    </a>`;

                                    }
                                }
                            }
                            return (`<div class="gallery" style="position: initial;">${images}</div>`);
                        }
                        return this.origin.code.apply(this, arguments);
                    }
                }
            },
            // complete configuration parameters
            search: {
                maxAge: 86400000, // Expiration time, the default one day
                paths: "auto",
                placeholder: "Type to search",
                noData: "No Results!",
                depth: 6,
                hideOtherSidebarContent: false, // whether or not to hide other sidebar content
            },
            plugins: [
                function (hook) {
                    hook.doneEach(() => {
                        // gallery
                        // do not init gallery if not loaded into dom
                        if (!document.querySelector(".gallery")) {
                            return;
                        }
                        new SimpleLightbox(".gallery a");
                    });
                },
                tfTracker
            ],

            mindmap: {
                preset: "colorful", // or default
                linkShape: "diagonal" // or bracket
            },

            charty: {},
        }

      </script>
      <script src="docsify.min.js"></script>
      <script src="docsify-example-panels.js"></script>
      <script src="prism-bash.min.js"></script>
      <script src="prism-python.min.js"></script>
      <script src="prism-v.min.js"></script>
      <script src="prism-typescript.min.js"></script>
      <script src="prism-go.min.js"></script>
      <script src="prism-graphql.min.js"></script>
      <script src="search.min.js"></script>
      <script src="docsify-remote-markdown.min.js"></script>
      <script src="docsify-tabs@1.js"></script>
      <script src="docsify-themeable@0.js"></script>
      <script src="docsify-sidebar-collapse.min.js"></script>
      <script src="zoom-image.min.js"></script>
      <script src="docsify-copy-code.js"></script>
      <script src="docsify-glossary.min.js"></script>
      <script src="simple-lightbox.min.js"></script>
      <script src="mermaid.min.js"></script>
      <script src="docsify-mermaid.js"> 
      <script>mermaid.initialize({ startOnLoad: true, securityLevel:"loose" });</script>
      <script src="docsify-mindmap.min.js"></script>
      <link rel="stylesheet" href="docsify-charty.min.css">
      <link rel="stylesheet" href="charty-custom-style.css">
      <script src="docsify-charty.min.js"></script>

      <script>
    // add favicon link
        var link = document.querySelector("link[rel~=\"icon\"]");
        if (!link) {
            link = document.createElement("link");
            link.rel = "icon";
            document.getElementsByTagName("head")[0].appendChild(link);

        }
        var ref = document.location.href.replace("#/", "")
        if(!ref.endsWith("/")){
            ref = ref + "/"
        }
        link.href =  ref + "favicon.ico";
        console.log(link)
        
    </script>
    </body>
    
    </html>
    '

	mut out := index_wiki
	out = out.replace('@reponame', reponame)
	out = out.replace('@repourl', repourl)
	out = out.replace('@trackingid', trackingid)
	out = out.replace('@crispwebsiteid', crispwebsiteid)

	out = out.replace('@og_url', opengraph.url)
	out = out.replace('@og_title', opengraph.title)
	out = out.replace('@og_type', opengraph.type_)
	out = out.replace('@og_description', opengraph.description)
	out = out.replace('@og_image_width', opengraph.image_width)
	out = out.replace('@og_image_height', opengraph.image_height)
	out = out.replace('@og_image', opengraph.image)

	return out
}

fn template_wiki_root_save(destdir string, reponame string, repourl string, trackingid string, opengraph publisher_config.OpenGraph) ? {
	out := template_wiki_root(reponame, repourl, trackingid, opengraph)?
	os.write_file('$destdir/index.html', out)?
}
