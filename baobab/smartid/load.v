module smartid
import regex
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools.regext

[params]
struct LoadArgs{
pub mut:
	path string	
	content string
	cid string
}

// load from a textfile, find all smart id's
pub fn load(args_ LoadArgs) ! {
	mut args:=args_
	if args.path.len>0{
		mut p:=pathlib.get_file(args.path,false)!
		args.content = p.read()!
	}
	sids_set(args.content,args.cid)!
}

//set the sids in redis, so we remember them all, and we know which one is the latest
fn sids_set(text string,cid string)!{
	res:=regext.find_sid(text)
	for sid in res{
		sid_aknowledge(sid,cid)!
	}
}

//find parts of text in form sid:*** till sid:******  .
//also support  sid:'***' till sid:'******'
//replace all occurrences with new sid's which are unique
fn sids_empty_replace(txt_ string,cid string)!txt{
	mut txt:=txt_
	pattern := r'sid:[\*]{3,6}[\s$]'
	mut re := regex.regex_opt(pattern) or { panic(err) }
	// re.replace_by_fn(txt,sid_empty_replace_unit)
	for _ in 0..1000{
		mut words := re.find_all_str(txt)
		if words.len==0{
			break //go out of outer loop, means we replaced all
		}
		for mut word in words{
			//now replace the first found one, we can't replace them all
			word2:=word.trim_space()//needed because of regex
			sidnew:=sid_new(cid)!
			word3:=word.replace(word2,"sid:${sidnew}") //to maintain line ending
			txt=txt.replace_once(word, word3)
			break //go out of inner loop
		}
	}
	return txt

}
