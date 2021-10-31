module taiga
import time
pub fn parse_time(date_time string) time.Time {
	return time.parse_iso8601(date_time) or {panic("Error during parsing time, error details: $err")}
}

