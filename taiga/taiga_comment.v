module taiga

import despiegk.crystallib.texttools
import json
import time { Time }
import x.json2 { raw_decode }

struct Commentator {
pub mut:
	id        int    [json: pk]
	name      string
	username  string
	is_active bool
}

struct Comment {
pub mut:
	id                  string
	comment             string
	user                Commentator
	created_at          Time        [skip]
	key                 string
	comment_html        string
	delete_comment_date Time        [skip]
	delete_comment_user string
	edit_comment_date   Time        [skip]
	is_hidden           bool
}

// return vlang clean object
pub fn comments_get(prefix string, prefix_id int) ?[]Comment {
	mut conn := connection_get()
	data := conn.get_json_str('history/$prefix/$prefix_id?type=comment', '', true) ?
	clean_data := texttools.ascii_clean(data)
	data_as_arr := (raw_decode(clean_data) or {}).arr()
	mut comments := []Comment{}
	for c in data_as_arr {
		comment := comment_decode(c.str()) or{
			eprintln(err)
			Comment{}
		}
		if comment != Comment{} {
			comments << comment
		}
	}
	return comments
}

fn comment_decode(data string) ?Comment {
	mut comment := json.decode(Comment, data) or {
		return error('Error happen when decode comment\nData: $data\nError:$err')
	}
	data_as_map := (raw_decode(data) or {}).as_map()
	comment.created_at = parse_time(data_as_map['created_at'].str())
	comment.delete_comment_date = parse_time(data_as_map['delete_comment_date'].str())
	comment.edit_comment_date = parse_time(data_as_map['edit_comment_date'].str())
	return comment
}
