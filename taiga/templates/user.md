# [@user.username](@url/profile/@user.username)
- ID: @user.id
- Full name: @user.full_name
- Biography: @user.bio
- Email: @user.email
- Active state: @user.is_active


# Projects
@for project in projects_md
$project
@end