module taiga

import json
import time { Time }
import x.json2 {raw_decode}

struct Commentator{
pub mut:
	id int [json:pk]
	name string
	username string
	is_active bool
}

struct Comment {
pub mut:
	id                  string
	comment             string
	user                Commentator
	created_at          Time [skip]
	commnet_type        int
	key                 string
	comment_html        string
	delete_comment_date Time [skip]
	delete_comment_user string
	edit_comment_date   Time [skip]
	is_hidden           bool
}

// return vlang clean object
pub fn comments_get(prefix string, prefix_id int) ? []Comment {
	mut conn := connection_get()
	data := conn.get_json_str("history/$prefix/$prefix_id?type=comment", "", true) ?
	data_as_arr := (raw_decode(data) or {}).arr()
		mut comments := []Comment{}
		for c in data_as_arr {
			comment := comment_decode(c.str()) ?
			comments << comment
		}
		return comments
	// fill in times...
	// if other objects look for them and get reference to them
	// use conn.user_get(user_id) to get user  ...
}

fn comment_decode(data string) ?Comment{
	mut comment := json.decode(Comment, data) ?
	data_as_map := (raw_decode(data) or {}).as_map()
	comment.created_at = parse_time(data_as_map["created_at"].str())
	comment.delete_comment_date = parse_time(data_as_map["delete_comment_date"].str())
	comment.edit_comment_date = parse_time(data_as_map["edit_comment_date"].str())
	return comment
}