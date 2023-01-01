module @actor.name

@{model.comments_str()}
pub struct @{model.name} {
pub mut:
@for field in model.fields
	@field.name @field.typestr 
@end
}

