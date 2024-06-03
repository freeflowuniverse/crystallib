module juggler

pub fn get(j Juggler) !&Juggler {
	return &Juggler{...j}
}