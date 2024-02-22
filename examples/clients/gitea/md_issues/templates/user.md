# @{user.username}

- Full name: @{user.full_name}
- Email: @{user.email}
- Avatar: [Gitea](@{user.avatar_url})
- Created: @{user.User.created}
@if user.created.len > 0
## Issues created
@for issue in user.created
- [@{issue.repository.full_name}/@{issue.title}](../issues/@{issue.name})
@end
@end
@if user.assigned.len > 0
## Assigned Issues
@for issue in user.assigned
- [@{issue.repository.full_name}/@{issue.title}](../issues/@{issue.name})
@end
@end