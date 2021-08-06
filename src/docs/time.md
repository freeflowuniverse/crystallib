
## Time


https://vlang.io/pkg/time


fn now() Time
fn random() Time
fn unix(u string) Time
fn unixn(uni int) Time
fn (t Time) format() string
fn (t Time) hhmm() string
fn (t Time) hhmm12() string
fn parse(s string) Time
`parse` parses time in the following format: "2018-01-27 12:48:34"

fn (t Time) add_seconds(seconds int) Time
fn (t Time) relative() string
fn (t Time) day_of_week() int