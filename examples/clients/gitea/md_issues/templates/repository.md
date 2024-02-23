# @{repo.full_name}

@if repo.issues.len > 0
## Issues
@for issue in repo.issues
- [@{issue.title}](../issues/@{issue.name})
@end
@end