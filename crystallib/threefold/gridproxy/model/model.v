module model

import time { Time }
import math { floor, pow10 }

type ByteUnit = u64

pub fn (u ByteUnit) to_megabytes() f64 {
	return f64(u) / 1e+6
}

pub fn (u ByteUnit) to_gigabytes() f64 {
	return f64(u) / 1e+9
}

pub fn (u ByteUnit) to_terabytes() f64 {
	return f64(u) / 1e+12
}

pub fn (u ByteUnit) str() string {
	if u >= 1e+12 {
		return '${u.to_terabytes():.2} TB'
	} else if u >= 1e+9 {
		return '${u.to_gigabytes():.2} GB'
	} else if u >= 1e+6 {
		return '${u.to_megabytes():.2} MB'
	}
	return '${u64(u)} Bytes'
}

// SecondUnit represents a duration in seconds
type SecondUnit = u64

pub fn (u SecondUnit) to_minutes() f64 {
	return f64(u) / 60
}

pub fn (u SecondUnit) to_hours() f64 {
	return f64(u) / (60 * 60)
}

pub fn (u SecondUnit) to_days() f64 {
	return f64(u) / (60 * 60 * 24)
}

pub fn (u SecondUnit) str() string {
	sec_num := u64(u)
	d := floor(sec_num / 86400)
	h := math.fmod(floor(sec_num / 3600), 24)
	m := math.fmod(floor(sec_num / 60), 60)
	s := sec_num % 60
	mut str := ''
	if d > 0 {
		str += '${d} days '
	}
	if h > 0 {
		str += '${h} hours '
	}
	if m > 0 {
		str += '${m} minutes '
	}
	if s > 0 {
		str += '${s} seconds'
	}
	return str
}

// UnixTime represent time in seconds since epoch (timestamp)
type UnixTime = u64

pub fn (t UnixTime) to_time() Time {
	return time.unix(t)
}

pub fn (t UnixTime) str() string {
	return '${t.to_time().local()}'
}

// this is the smallest unit used to calculate the billing and and the one natively fetched from the API
// 1 TFT = 10_000_000 drops = 1_000 mTFT = 1_000_000 uTFT
type DropTFTUnit = u64

pub fn (t DropTFTUnit) to_tft() f64 {
	return f64(t) / pow10(7) // 1 TFT = 10_000_000 drops
}

pub fn (t DropTFTUnit) to_mtft() f64 {
	return f64(t) / pow10(4) // 1 mTFT (milliTFT) = 10_000 drops
}

pub fn (t DropTFTUnit) to_utft() f64 {
	return f64(t) / 10.0 // 1 uTFT (microTFT) = 10 drops
}

pub fn (u DropTFTUnit) str() string {
	if u >= pow10(7) {
		return '${u.to_tft():.3} TFT'
	} else if u >= pow10(4) {
		return '${u.to_mtft():.3} mTFT'
	} else if u >= 10 {
		return '${u.to_utft():.3} uTFT'
	}
	return '${u64(u)} dTFT' // Short for dropTFT (1 TFT = 10_000_000 drops). dylan suggests the name and i'm using this till we have an officail name!
}

struct EmptyOption {}
