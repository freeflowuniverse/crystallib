# Taiga exports

Taiga full project exports that supports async/sync export API.


## Usage

```v
module main

import taigaexports

fn main()
	url := "https://circles.threefold.me"
	mut exporter := taigaexports.new(url, "myuser", "mypassword") or {
		println("cannot get an exporter for $url")
		panic(err)
	}

	export := exporter.export_project(100, "myuser-project_alpha") or {
		println("error while exporting project of $args.project_id:$args.project_slug")
		panic(err)
	}

	println(export)
}
```
