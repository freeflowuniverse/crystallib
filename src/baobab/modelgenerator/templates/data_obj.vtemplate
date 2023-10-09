module @actor.name
@for mut item in model.imports
@item
@end

@{model.comments_str()}
pub struct @{model.name} {
pub mut:
@for mut field in model.fields
	@field.name @field.typestr @{field.comments_str()}
@end
}

