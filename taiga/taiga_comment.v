module taiga
import despiegk.crystallib.crystaljson
import texttools
import json
import time { Time }

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
	blocks := conn.get_json_list('history/$prefix/$prefix_id?type=comment', '', true) ?
	mut comments := []Comment{}
	for c in blocks {
		comment := comment_decode(c.str()) or {
			eprintln(err)
			Comment{}
		}
		if comment != Comment{} {
			println(comment)
			comments << comment
		}
	}
	return comments
}

fn comment_decode(data string) ?Comment {
	mut comment := json.decode(Comment, data) or {
		return error('Error happen when decode comment\nData: $data\nError:$err')
	}
	data_as_map := crystaljson.json_dict_any(data,false,[],[])?
	comment.created_at = parse_time(data_as_map['created_at'].str())
	comment.delete_comment_date = parse_time(data_as_map['delete_comment_date'].str())
	comment.edit_comment_date = parse_time(data_as_map['edit_comment_date'].str())
	return comment
}
