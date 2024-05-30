module flist

fn (mut f Flist) add_block(block Block)!{
	sql f.con {
		insert block into Block
	}!
}

fn do_blocks_match(b1 []Block, b2 []Block) bool {
	if b1.len != b2.len {
		return false
	}

	for i, b in b1 {
		if b.key != b2[i].key || b.id != b2[i].id {
			return false
		}
	}

	return true
}

fn (mut f Flist) get_inode_blocks(ino u64) ![]Block {
	blocks := sql f.con {
		select from Block where ino == ino
	}!

	return blocks
}

fn (mut f Flist) delete_block(ino u64)!{
	f.con.exec_param('delete from block where ino = ?;', '${ino}')!
}