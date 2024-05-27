module console
import freeflowuniverse.crystallib.ui.console

// print 2 dimensional array, delimeter is between columns
pub fn print_array(arr [][]string, delimiter string, sort bool) {
	if arr.len == 0 {
		return
	}

	mut maxwidth := []int{len: arr[0].len, cap: arr[0].len, init: 3}
	mut x := 0
	mut y := 0
	for y < arr.len {
		for x < arr[y].len {
			if maxwidth[x] < arr[y][x].len {
				maxwidth[x] = arr[y][x].len
			}
			x++
		}
		x = 0
		y++
	}

	x = 0
	y = 0
	mut res := []string{}
	for y < arr.len {
		mut row := ''
		for x < arr[y].len {
			row += expand(arr[y][x], maxwidth[x], ' ') + delimiter
			x++
		}
		res << row
		x = 0
		y++
	}
	if sort {
		res.sort_ignore_case()
	}
	// console.print_debug(res)
	print_stdout(res.join_lines())
}

// expand text till length l, with string which is normally ' '
pub fn expand(txt_ string, l int, with string) string {
	mut txt := txt_
	if l > txt.len {
		extra := l - txt.len
		txt += with.repeat(extra)
	}
	return txt
}
