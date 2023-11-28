module model

@[inherit: 'base']
@[root]
pub struct Group {
pub mut:
	users []u32
}
