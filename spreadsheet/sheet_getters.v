module spreadsheet

fn remove_empty_line(txt string) string {
	mut out := ''
	for line in txt.split_into_lines() {
		if line.trim_space() == '' {
			continue
		}
		out += '${line}\n'
	}
	return out
}

[params]
pub struct RowGetArgs {
pub mut:
	rowname       string   // only include the exact names as secified for the row (if only one row)
	include       []string // to use with params filter e.g. ['location:belgium_*'] //would match all words starting with belgium
	exclude       []string
	period_type   PeriodType       // year, month, quarter
	aggregate     bool = true // if more than 1 row matches should we aggregate or not
	aggregatetype RowAggregateType = .sum // important if used with include/exclude, because then we group
	unit          UnitType
	title         string
	title_sub     string
	size          string
}

pub enum UnitType {
	normal
	thousand
	million
	billion
}

pub enum PeriodType {
	year
	month
	quarter
	error
}

// return e.g. "'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6'" if year, is for header
pub fn (mut s Sheet) header_get_as_list(period_type PeriodType) ![]string {
	str := s.header_get_as_string(period_type)!
	return str.split(',')
}

// return e.g. "'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6'" if year, is for header
pub fn (mut s Sheet) data_get_as_list(args RowGetArgs) ![]string {
	str := s.data_get_as_string(args)!
	return str.split(',')
}

// return e.g. "'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6'" if year, is for header
pub fn (mut s Sheet) header_get_as_string(period_type PeriodType) !string {
	err_pre := "Can't get header for sheet:${s.name}\n"
	period_type_s := match period_type {
		.year {
			"'Y1', 'Y2', 'Y3', 'Y4', 'Y5'"
		}
		.quarter {
			mut out := ''
			for i in 1 .. (6 * 4 + 1) {
				out += "'Q${i}' "
			}
			return out
		}
		.month {
			mut out := ''
			for i in 1 .. (12 * 6 + 1) {
				out += "'M${i}' "
			}
			return out
		}
		else {
			return error('${err_pre}Period type not well specified')
		}
	}
	return period_type_s
}

// return the values
pub fn (mut s Sheet) data_get_as_string(args RowGetArgs) !string {
	nryears := 5
	err_pre := "Can't get data for sheet:${s.name} row:${args.rowname}.\n"
	mut s2 := s
	if args.period_type == .year {
		s2 = s.toyear()!
	}
	if args.period_type == .quarter {
		s2 = s.toquarter()!
	}
	mut out := ''
	// println(s2.row_get(args.rowname)!)
	mut vals := s2.values_get(args.rowname)!
	if args.period_type == .year && vals.len != nryears {
		return error('${err_pre}Vals.len need to be 6, for year.\nhere:\n${vals}')
	}
	if args.period_type == .quarter && vals.len != nryears * 4 {
		return error('${err_pre}vals.len need to be 5*4, for quarter.\nhere:\n${vals}')
	}
	if args.period_type == .month && vals.len != nryears * 12 {
		return error('${err_pre}vals.len need to be 6*12, for month.\nhere:\n${vals}')
	}
	for mut val in vals {
		if args.unit == .thousand {
			val = val / 1000.0
		}
		if args.unit == .million {
			val = val / 1000000.0
		}
		if args.unit == .billion {
			val = val / 1000000000.0
		}
		out += ',${val}'
	}
	return out.trim(',')
}
