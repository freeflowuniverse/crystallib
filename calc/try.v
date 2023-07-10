pub struct Sheet {
pub mut:
	raw_data   string
	data       [][]string
}

pub fn (mut s Sheet) parse() {
	lines := s.raw_data.split_into_lines()
    for line in lines {
        cells := line.split(",")
		s.data << cells
    }
}

pub fn (mut s Sheet) to_md() string {
	mut md := ""
	for idx, row in s.data {
		for cell in row {
			md += "|" + cell 
		}
		md += "|\n"

		if idx == 0 {
			for _ in 0..row.len {
				md += "|---"
			}
			md += "|\n"
		}
	}
	return md
}

pub fn (mut s Sheet) to_html(styles string) string {
	mut level := "td"
	mut html := "<table>\n"
	for idx, row in s.data {
		if idx == 0 {
			level = "th"
		} else {
			level = "td"
		}
		html += "<tr>\n"
		for cell in row {
			html += "<$level>" + cell + "</$level>\n"
		}
		html += "</tr>\n"
	}
	html += "</table>\n"
	html += "<style>\n$styles\n</style>"
	return html
}

pub fn (mut s Sheet) to_json() []map[string]string {
	mut json_list := []map[string]string{}
	for row in s.data[1..] {
    	mut row_dict := map[string]string
		for idx, cell in row {
			row_dict[s.data[0][idx]] = cell
		}
		json_list << row_dict
	}
	return json_list
}

// reader from files

// wrtier into files

fn main() {
	mut sh := Sheet{}
	sh.raw_data = 
"Name,Position,Salary
Foo,SWE ,0
Bar,SWE II,0
Baz,SWE,0"
	sh.parse()
	println(sh.data)
	println("")
	println(sh.to_md())	
	println("")
	println(sh.to_html("table,
  th,
  tr,
  td {
    border: 1px solid;
  }"))
	println("")
	foo := sh.to_json()
	println(foo[0]["Name"])
}
