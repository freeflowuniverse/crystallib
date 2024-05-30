module flist

fn (mut f Flist) get_extra(ino u64) ?Extra{
	extra := sql f.con{
		select from Extra where ino == ino
	} or { return none }

	if extra.len == 0{
		return none
	}

	return extra[0]
}

fn (mut f Flist) copy_extra(src_ino u64, dest_ino u64) ! {
	if mut extra := f.get_extra(src_ino){
		extra.ino = dest_ino
		sql f.con {
			insert extra into Extra
		}!
	}
}

fn (mut f Flist) delete_extra(ino u64)!{
	f.con.exec_param('delete from extra where ino = ?;', '${ino}')!
}

fn (mut f Flist) add_extra(extra Extra) !{
	sql f.con {
		insert extra into Extra
	}!
}