# @{issue.title}

[Gitea](@{issue.html_url}) | [JSON](@{issue.url})

- User: [@{issue.user.username}](@{issue.user.avatar_url})
- Repository: [@{issue.repository.name}](@{issue.user.avatar_url})
- Assignee(s): @{assignees_str}
- Milestone: @{issue.milestone or {'none'}}
- Labels: @{issue.labels}
- Created at: @{issue.created_at}
- Updated at: @{issue.updated_at}

@{issue.body}