# Users

| Name | Links |
| ---- | ----- |
@for user in all_users
| $user.full_name | [link](@url/profile/$user.username) \| [md](./users/$user.file_name) |
@end
