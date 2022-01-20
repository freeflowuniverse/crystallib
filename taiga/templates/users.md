# Users

| Name | Links |
| ---- | ----- |
@for user in all_users
| $user.full_name | [wiki](./users/$user.file_name) \| [web](@url/profile/$user.username) |
@end
