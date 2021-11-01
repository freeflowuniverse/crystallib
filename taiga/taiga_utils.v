module taiga
import time
pub fn parse_time(date_time string) time.Time {
	if date_time == "null"{
		return time.Time{}
	}
	return time.parse_iso8601(date_time) or {time.Time{}}
}
