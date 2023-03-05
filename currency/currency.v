module currency


[heap]
pub struct Currencies {
pub mut:
	currencies map[string]Currency
}

pub struct Currency {
pub mut:
	name   string
	usdval f64
}




pub fn (mut cs Currencies) currency_get(name_ string) !Currency {
	mut name:=name_.to_upper().trim_space()
	return cs.currencies[name] or {
		return error("Could not find currency $name")
	}

}