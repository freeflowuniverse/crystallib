import sqlite
import main
fn main2() {

	db := sqlite.connect('foo.db') or { panic(err) }
	db.synchronization_mode(sqlite.SyncMode.off)
	db.journal_mode(sqlite.JournalMode.memory)
}