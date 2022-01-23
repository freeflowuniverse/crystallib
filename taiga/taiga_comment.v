module taiga
import despiegk.crystallib.crystaljson
import texttools
import json
import time { Time }

struct Comment {
pub mut:
	id                  string
	comment             string
	user_id             int //should just refer to the id of the user who did the comment
	created_at          Time 
	key                 string
	comment_html        string
	delete_comment_date Time 
	delete_comment_user string
	edit_comment_date   Time 
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

	//TODO: use raw json data_as_map feature to link to object, do all the others
	//TODO: when a user, project, ... find it in the memdb to get right id

	data_as_map := crystaljson.json_dict_any(data,false,[],[])?

	mut comment := Comment{
		//TODO:
	}

	comment.created_at = parse_time(data_as_map['created_at'].str())
	comment.delete_comment_date = parse_time(data_as_map['delete_comment_date'].str())
	comment.edit_comment_date = parse_time(data_as_map['edit_comment_date'].str())
	return comment
}
