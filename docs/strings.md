# string

- fn (s array) slice(start, _end int) array
- fn (s string) replace(rep, with string) string
- fn (s string) to_i() int
- fn (s string) split(delim string) []string
- fn (s string) split_into_lines() []string
- fn (s string) left(n int) string
- fn (s string) right(n int) string
- fn (s string) substr(start, end int) string
- fn (s string) index(p string) int
- fn (s string) last_index(p string) int
- fn (s string) index_after(p string, start int) int
- fn (s string) contains(p string) bool
- fn (s string) starts_with(p string) bool
- fn (s string) ends_with(p string) bool
- fn (s string) to_lower() string
- fn (s string) to_upper() string
- fn (s string) trim_space() string
- fn (s string) trim(c byte) string
- fn (s mut []string) sort()
- fn (s string) free()
- fn (a[]string) join(del string) string
- fn (s string) hash() int


## program mgmt

- fn exit(reason string)
- fn isnil(v voidptr) bool
  - `isnil` returns true if an object is nil (only for C objects).
- fn panic(s string)
- fn error(s string) Option

## printing / error

- fn println(s string)
- fn eprintln(s string)
- fn print(s string)

# map

- fn (m mut map) sort()