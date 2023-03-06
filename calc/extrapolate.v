module calc

// import freeflowuniverse.crystallib.texttools

//extrapolate years
//eg growth [0,1,2,4,10], would give us 4 years starting from 0 going to 10
pub fn extrapolate(growth []f64) []f64{
	mut months := []f64{}
	for year in 1..growth.len{
		val_start := growth[year-1]
		val_end := growth[year]
		increment := (val_end-val_start)/11
		for m in 0..12{
			months << val_start+increment * m
		}
	}
	return months
}

pub fn extrapolate_int(vals []int) []int{
	vals2 := extrapolate(array2float(vals))
	return array2int(vals2)
}

//will grow following a curve and then shows how per month we need to grow, how much to add
//e.g. [0,0,0,0,0,10] means we 
pub fn extrapolate_growth(vals []int) []int{
	mut prev := 0 
	mut res := []int
	mut additional := 0 
	for i in extrapolate_int(vals){
		if i>prev{
			additional = i - prev
			prev = i
			res << additional
		}else{
			res << 0
		}
	}
	return res
}



// //add X months to the input
// pub fn extrapolate_addmonths(growth []f64, nrmonthts int) []f64{
// 	mut months := []f64{}
// 	mut growth2 := growth.clone()
// 	for _ in 1..growth.len{
// 		growth2 << growth[growth.len-1]
// 	}
// 	for year in 1..growth2.len{
// 		val_start := growth2[year-1]
// 		val_end := growth2[year]
// 		increment := (val_end-val_start)/11
// 		for m in 0..12{
// 			months << val_start+increment * m
// 		}
// 	}
// 	return months
// }


// something like 3:2,10:5 means month 3 we start with 2, it grows to 5 on month 10
// the cells out of the mentioned ranges are not filled if they are already set
// the cells which are empty at start of row will go from 0 to the first val
// the cells which are empty at the back will just be same value as the last one
pub fn (mut r Row) extrapolate_smart (smartstr string) !&Cell {
	res:=[]f32
	for mut part in smartstr.split(","){
		part:=part.trim_space()
		if part.contains(":"}{
			splitted:=part.split(":")
			if splitted.len!=2{
				return error("smartextrapolate needs '3:2,10:5' as format, now $smartstr ")
			}
			x:=splitted[0].int()
			v:=splitted[1].f32()
			
		}
	}
	

}



