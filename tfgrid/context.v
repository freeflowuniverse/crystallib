module tfgrid
import os

struct Context{
	path string
}

pub fn (ctx Context) init() ?{
	os.mkdir_all(ctx.path) ?
}
