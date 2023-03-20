module calc

pub fn array2float(list []int) []f64 {
	mut list2 := []f64{}
	for i in list {
		list2 << f64(i)
	}
	return list2
}

pub fn array2int(list []f64) []int {
	mut list2 := []int{}
	for i in list {
		list2 << int(i)
	}
	return list2
}
