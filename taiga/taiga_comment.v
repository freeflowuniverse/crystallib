module taiga

import x.json2
import despiegk.crystallib.crystaljson

// return vlang clean object
pub fn comments_get(prefix string, prefix_id int) ?[]Comment {
	mut conn := connection_get()
	mut comments := []Comment{}
	if prefix_id != 0 {
		blocks := conn.get_json_list('history/$prefix/$prefix_id?type=comment', '', true) ?
		for c in blocks {
			comment := comment_decode(c.str()) or {
				eprintln(err)
				Comment{}
			}
			if comment != Comment{} {
				comments << comment
			}
		}
	}
	return comments
}

fn comment_decode(data string) ?Comment {
	data_as_map := crystaljson.json_dict_any(data, false, [], []) ?

	mut comment := Comment{
		id: data_as_map['id'].str()
		comment: data_as_map['comment'].str()
		key: data_as_map['key'].str()
		// comment_html: data_as_map['comment_html'].str()
		delete_comment_user: data_as_map['delete_comment_user'].str()
		is_hidden: data_as_map['is_hidden'].bool()
	}
	comment.user_id = data_as_map['user'].as_map()['pk'].int()
	comment.created_at = parse_time(data_as_map['created_at'].str())
	comment.delete_comment_date = parse_time(data_as_map['delete_comment_date'].str())
	comment.edit_comment_date = parse_time(data_as_map['edit_comment_date'].str())
	return comment
}

pub fn (comment Comment) user() User {
	conn := connection_get()
	return *conn.users[comment.user_id]
}
