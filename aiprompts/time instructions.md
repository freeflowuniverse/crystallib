
## Description

V's `time` module, provides utilities for working with time and dates:

- parsing of time values expressed in one of the commonly used standard time/date formats
- formatting of time values
- arithmetic over times/durations
- converting between local time and UTC (timezone support)
- stop watches for accurately measuring time durations
- sleeping for a period of time

## Examples

You can see the current time. [See](https://play.vlang.io/?query=c121a6dda7):

```v
import time

println(time.now())
```

`time.Time` values can be compared, [see](https://play.vlang.io/?query=133d1a0ce5):

```v
import time

const time_to_test = time.Time{
	year:       1980
	month:      7
	day:        11
	hour:       21
	minute:     23
	second:     42
	nanosecond: 123456789
}

println(time_to_test.format())

assert '1980-07-11 21:23' == time_to_test.format()
assert '1980-07-11 21:23:42' == time_to_test.format_ss()
assert '1980-07-11 21:23:42.123' == time_to_test.format_ss_milli()
assert '1980-07-11 21:23:42.123456' == time_to_test.format_ss_micro()
assert '1980-07-11 21:23:42.123456789' == time_to_test.format_ss_nano()
```

You can also parse strings to produce time.Time values,
[see](https://play.vlang.io/p/b02ca6027f):

```v
import time

s := '2018-01-27 12:48:34'
t := time.parse(s) or { panic('failing format: ${s} | err: ${err}') }
println(t)
println(t.unix())
```

V's time module also has these parse methods:

```v ignore
fn parse(s string) !Time
fn parse_iso8601(s string) !Time
fn parse_rfc2822(s string) !Time
fn parse_rfc3339(s string) !Time
```

Another very useful feature of the `time` module is the stop watch,
for when you want to measure short time periods, elapsed while you
executed other tasks. [See](https://play.vlang.io/?query=f6c008bc34):

```v
import time

fn do_something() {
	time.sleep(510 * time.millisecond)
}

fn main() {
	sw := time.new_stopwatch()
	do_something()
	println('Note: do_something() took: ${sw.elapsed().milliseconds()} ms')
}
```

```vlang

module time

const second = Duration(1000 * millisecond)
const long_months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
	'September', 'October', 'November', 'December']
const nanosecond = Duration(1)
const absolute_zero_year = i64(-292277022399)
const days_string = 'MonTueWedThuFriSatSun'
const long_days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']!
const month_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]!
const seconds_per_hour = 60 * seconds_per_minute
const millisecond = Duration(1000 * microsecond)
const days_per_4_years = days_in_year * 4 + 1
const microsecond = Duration(1000 * nanosecond)
const days_per_400_years = days_in_year * 400 + 97
const minute = Duration(60 * second)
const days_before = [
	0,
	31,
	31 + 28,
	31 + 28 + 31,
	31 + 28 + 31 + 30,
	31 + 28 + 31 + 30 + 31,
	31 + 28 + 31 + 30 + 31 + 30,
	31 + 28 + 31 + 30 + 31 + 30 + 31,
	31 + 28 + 31 + 30 + 31 + 30 + 31 + 31,
	31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30,
	31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31,
	31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30,
	31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30 + 31,
]!
const months_string = 'JanFebMarAprMayJunJulAugSepOctNovDec'
const seconds_per_week = 7 * seconds_per_day
const hour = Duration(60 * minute)
const days_per_100_years = days_in_year * 100 + 24
const seconds_per_minute = 60
const days_in_year = 365
const infinite = Duration(i64(9223372036854775807))
const seconds_per_day = 24 * seconds_per_hour
fn date_from_days_after_unix_epoch(days int) Time
fn day_of_week(y int, m int, d int) int
fn days_from_unix_epoch(year int, month int, day int) int
fn days_in_month(month int, year int) !int
fn is_leap_year(year int) bool
fn new(t Time) Time
fn new_stopwatch(opts StopWatchOptions) StopWatch
fn new_time(t Time) Time
fn now() Time
fn offset() int
fn parse(s string) !Time
fn parse_format(s string, format string) !Time
fn parse_iso8601(s string) !Time
fn parse_rfc2822(s string) !Time
fn parse_rfc3339(s string) !Time
fn portable_timegm(t &C.tm) i64
fn since(t Time) Duration
fn sleep(duration Duration)
fn sys_mono_now() u64
fn ticks() i64
fn unix(epoch i64) Time
fn unix2(epoch i64, microsecond int) Time
fn unix_microsecond(epoch i64, microsecond int) Time
fn unix_nanosecond(abs_unix_timestamp i64, nanosecond int) Time
fn utc() Time
fn Time.new(t Time) Time
type Duration = i64
fn (d Duration) days() f64
fn (d Duration) debug() string
fn (d Duration) hours() f64
fn (d Duration) microseconds() i64
fn (d Duration) milliseconds() i64
fn (d Duration) minutes() f64
fn (d Duration) nanoseconds() i64
fn (d Duration) seconds() f64
fn (d Duration) str() string
fn (d Duration) sys_milliseconds() int
fn (d Duration) timespec() C.timespec
enum FormatDate {
	ddmmyy
	ddmmyyyy
	mmddyy
	mmddyyyy
	mmmd
	mmmdd
	mmmddyy
	mmmddyyyy
	no_date
	yyyymmdd
	yymmdd
}
enum FormatDelimiter {
	dot
	hyphen
	slash
	space
	no_delimiter
}
enum FormatTime {
	hhmm12
	hhmm24
	hhmmss12
	hhmmss24
	hhmmss24_milli
	hhmmss24_micro
	hhmmss24_nano
	no_time
}
struct C.mach_timebase_info_data_t {
	numer u32
	denom u32
}
struct C.timespec {
pub mut:
	tv_sec  i64
	tv_nsec i64
}
struct C.timeval {
pub:
	tv_sec  u64
	tv_usec u64
}
struct C.tm {
pub mut:
	tm_sec    int
	tm_min    int
	tm_hour   int
	tm_mday   int
	tm_mon    int
	tm_year   int
	tm_wday   int
	tm_yday   int
	tm_isdst  int
	tm_gmtoff int
}
struct StopWatch {
mut:
	elapsed u64
pub mut:
	start u64
	end   u64
}
fn (mut t StopWatch) start()
fn (mut t StopWatch) restart()
fn (mut t StopWatch) stop()
fn (mut t StopWatch) pause()
fn (t StopWatch) elapsed() Duration
struct StopWatchOptions {
pub:
	auto_start bool = true
}
struct Time {
	unix i64
pub:
	year       int
	month      int
	day        int
	hour       int
	minute     int
	second     int
	nanosecond int
	is_local   bool // used to make time.now().local().local() == time.now().local()

	microsecond int @[deprecated: 'use t.nanosecond / 1000 instead'; deprecated_after: '2023-08-05']
}
fn (lhs Time) - (rhs Time) Duration
fn (t1 Time) < (t2 Time) bool
fn (t1 Time) == (t2 Time) bool
fn (t Time) add(duration_in_nanosecond Duration) Time
fn (t Time) add_days(days int) Time
fn (t Time) add_seconds(seconds int) Time
fn (t Time) as_local() Time
fn (t Time) as_utc() Time
fn (t Time) clean() string
fn (t Time) clean12() string
fn (t Time) custom_format(s string) string
fn (t Time) day_of_week() int
fn (t Time) days_from_unix_epoch() int
fn (t Time) ddmmy() string
fn (t Time) debug() string
fn (t Time) format() string
fn (t Time) format_rfc3339() string
fn (t Time) format_rfc3339_nano() string
fn (t Time) format_ss() string
fn (t Time) format_ss_micro() string
fn (t Time) format_ss_milli() string
fn (t Time) format_ss_nano() string
fn (t Time) get_fmt_date_str(fmt_dlmtr FormatDelimiter, fmt_date FormatDate) string
fn (t Time) get_fmt_str(fmt_dlmtr FormatDelimiter, fmt_time FormatTime, fmt_date FormatDate) string
fn (t Time) get_fmt_time_str(fmt_time FormatTime) string
fn (t Time) hhmm() string
fn (t Time) hhmm12() string
fn (t Time) hhmmss() string
fn (t Time) http_header_string() string
fn (t Time) is_utc() bool
fn (t Time) local() Time
fn (t Time) local_to_utc() Time
fn (t Time) long_weekday_str() string
fn (t Time) md() string
fn (t Time) relative() string
fn (t Time) relative_short() string
fn (t Time) smonth() string
fn (t Time) str() string
fn (t Time) strftime(fmt string) string
fn (t Time) unix() i64
fn (t Time) unix_micro() i64
fn (t Time) unix_milli() i64
fn (t Time) unix_nano() i64
fn (t Time) unix_time() i64
fn (t Time) unix_time_micro() i64
fn (t Time) unix_time_milli() i64
fn (t Time) unix_time_nano() i64
fn (t Time) utc_string() string
fn (u Time) utc_to_local() Time
fn (t Time) weekday_str() string
fn (t Time) year_day() int
fn (t Time) ymmdd() string
struct TimeParseError {
	Error
	code    int
	message string
}
fn (err TimeParseError) msg() string

```