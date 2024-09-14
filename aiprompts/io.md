module io
    ## Description
    
    `io` provides common interfaces for buffered reading/writing of data.

const read_all_len = 10 * 1024
const read_all_grow_len = 1024
fn cp(mut src Reader, mut dst Writer) !
    cp copies from `src` to `dst` by allocating a maximum of 1024 bytes buffer for reading until either EOF is reached on `src` or an error occurs. An error is returned if an error is encountered during write.
fn make_readerwriter(r Reader, w Writer) ReaderWriterImpl
    make_readerwriter takes a rstream and a wstream and makes an rwstream with them.
fn new_buffered_reader(o BufferedReaderConfig) &BufferedReader
    new_buffered_reader creates a new BufferedReader.
fn new_multi_writer(writers ...Writer) Writer
    new_multi_writer returns a Writer that writes to all writers. The write function of the returned Writer writes to all writers of the MultiWriter, returns the length of bytes written, and if any writer fails to write the full length an error is returned and writing to other writers stops, and if any writer returns an error the error is returned immediately and writing to other writers stops.
fn read_all(config ReadAllConfig) ![]u8
    read_all reads all bytes from a reader until either a 0 length read or if read_to_end_of_stream is true then the end of the stream (`none`).
fn read_any(mut r Reader) ![]u8
    read_any reads any available bytes from a reader (until the reader returns a read of 0 length).
interface RandomReader {
	read_from(pos u64, mut buf []u8) !int
}
    RandomReader represents a stream of readable data from at a random location.
interface RandomWriter {
	write_to(pos u64, buf []u8) !int
}
    RandomWriter is the interface that wraps the `write_to` method, which writes `buf.len` bytes to the underlying data stream at a random `pos`.
interface Reader {
	// read reads up to buf.len bytes and places
	// them into buf.
	// A type that implements this should return
	// `io.Eof` on end of stream (EOF) instead of just returning 0
mut:
	read(mut buf []u8) !int
}
    Reader represents a stream of data that can be read.
interface ReaderWriter {
	Reader
	Writer
}
    ReaderWriter represents a stream that can be read and written.
interface Writer {
mut:
	write(buf []u8) !int
}
    Writer is the interface that wraps the `write` method, which writes `buf.len` bytes to the underlying data stream.
fn (mut r ReaderWriterImpl) read(mut buf []u8) !int
    read reads up to `buf.len` bytes into `buf`. It returns the number of bytes read or any error encountered.
fn (mut r ReaderWriterImpl) write(buf []u8) !int
    write writes `buf.len` bytes from `buf` to the underlying data stream. It returns the number of bytes written or any error encountered.
struct BufferedReadLineConfig {
pub:
	delim u8 = `\n` // line delimiter
}
    BufferedReadLineConfig are options that can be given to the read_line() function.
struct BufferedReader {
mut:
	reader Reader
	buf    []u8
	offset int // current offset in the buffer
	len    int
	fails  int // how many times fill_buffer has read 0 bytes in a row
	mfails int // maximum fails, after which we can assume that the stream has ended
pub mut:
	end_of_stream bool // whether we reached the end of the upstream reader
	total_read    int  // total number of bytes read
}
    BufferedReader provides a buffered interface for a reader.
fn (mut r BufferedReader) read(mut buf []u8) !int
    read fufills the Reader interface.
fn (mut r BufferedReader) free()
    free deallocates the memory for a buffered reader's internal buffer.
fn (r BufferedReader) end_of_stream() bool
    end_of_stream returns whether the end of the stream was reached.
fn (mut r BufferedReader) read_line(config BufferedReadLineConfig) !string
    read_line attempts to read a line from the buffered reader. It will read until it finds the specified line delimiter such as (\n, the default or \0) or the end of stream.
struct BufferedReaderConfig {
pub:
	reader  Reader
	cap     int = 128 * 1024 // large for fast reading of big(ish) files
	retries int = 2          // how many times to retry before assuming the stream ended
}
    BufferedReaderConfig are options that can be given to a buffered reader.
struct Eof {
	Error
}
    / Eof error means that we reach the end of the stream.
struct MultiWriter {
pub mut:
	writers []Writer
}
    MultiWriter writes to all its writers.
fn (mut m MultiWriter) write(buf []u8) !int
    write writes to all writers of the MultiWriter. Returns the length of bytes written. If any writer fails to write the full length an error is returned and writing to other writers stops. If any writer returns an error the error is returned immediately and writing to other writers stops.
struct NotExpected {
	cause string
	code  int
}
    NotExpected is a generic error that means that we receave a not expected error.
struct ReadAllConfig {
pub:
	read_to_end_of_stream bool
	reader                Reader
}
    ReadAllConfig allows options to be passed for the behaviour of read_all.
