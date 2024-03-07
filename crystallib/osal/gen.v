module osal

pub fn write_flags[T](options T) string {
	mut flags := []string{}
	$for field in T.fields {
		// val := options.$(field.name)
		$if field.typ is bool {
			$if field.is_option {
			}
			flag := options.$(field.name)
			if flag {
				flags << '--${field} ${flag}'
			}
		}
		$if field.typ is ?string {
			if options.$(field.name) != none {
				val := options.$(field.name) ?
				flags << '--${field.name} ${val}'
			}
		}
		$if field.typ is string {
			val := options.$(field.name)
			flags << '--${field.name} ${val}'
		}
	}
	return if flags.len > 0 { flags.join(' ') } else { '' }
}
