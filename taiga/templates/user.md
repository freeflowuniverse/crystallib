# @user.username

> [@user.username](@url/profile/@user.username)

- ID: @user.id
- Full name: @user.full_name
- Biography: @user.bio
- Email: @user.email
- Active state: @user.is_active

# Priorities
## Blocked
@if stories.filter(it.category == .blocked).len > 0 || issues.filter(it.category == .blocked).len > 0 || tasks.filter(it.category == .blocked).len > 0
| Type | project | Subject | Created at | Blocked Note | Link |
| ---- | ------- | ------- | ---------- | ------------ | ---- |
@for story in stories.filter(it.category == .blocked)
| UserStory |$story.project().name | $story.subject | $story.created_date.ymmdd() | $story.blocked_note | [wiki]($story.file_name) \| [web](@url/project/$story.project().slug/us/$story.ref) |
@end
@for issue in issues.filter(it.category == .blocked)
| Issue |$issue.project().name | $issue.subject | $issue.created_date.ymmdd() | $issue.blocked_note | [wiki]($issue.file_name) \| [web](@url/project/$issue.project().slug/issue/$issue.ref) |
@end
@for task in tasks.filter(it.category == .blocked)
| Task |$task.project().name | $task.subject | $task.created_date.ymmdd() | $task.blocked_note | [wiki]($task.file_name) \| [web](@url/project/$task.project().slug/task/$task.ref) |
@end
@else
- No blocked stories, issues and tasks.
@end
## Overdue
@if stories.filter(it.category == .overdue).len > 0 || issues.filter(it.category == .overdue).len > 0 || tasks.filter(it.category == .overdue).len > 0
| Type | project | Subject | Created at | Deadline | Link |
| ---- | ------- | ------- | ---------- | -------- | ---- |
@for story in stories.filter(it.category == .overdue)
| UserStory |$story.project().name | $story.subject | $story.created_date.ymmdd() | $story.due_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project().slug/us/$story.ref) |
@end
@for issue in issues.filter(it.category == .overdue)
| Issue |$issue.project().name | $issue.subject | $issue.created_date.ymmdd() | $issue.due_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project().slug/issue/$issue.ref) |
@end
@for task in tasks.filter(it.category == .overdue)
| Task |$task.project().name | $task.subject | $task.created_date.ymmdd() | $task.due_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project().slug/task/$task.ref) |
@end
@else
- No delayed stories, issues and tasks .
@end
## Today
@if stories.filter(it.category == .today).len > 0 || issues.filter(it.category == .today).len > 0 || tasks.filter(it.category == .today).len > 0
| Type | project | Subject | Created at | Link |
| ---- | ------- | ------- | ---------- | ---- |
@for story in stories.filter(it.category == .today)
| UserStory |$story.project().name | $story.subject | $story.created_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project().slug/us/$story.ref) |
@end
@for issue in issues.filter(it.category == .today)
| Issue |$issue.project().name | $issue.subject | $issue.created_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project().slug/issue/$issue.ref) |
@end
@for task in tasks.filter(it.category == .today)
| Task |$task.project().name | $task.subject | $task.created_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project().slug/task/$task.ref) |
@end
@else
- No stories, issues and tasks to be delivered today .
@end
## In 2 Days
@if stories.filter(it.category == .in_two_days).len > 0 || issues.filter(it.category == .in_two_days).len > 0 || tasks.filter(it.category == .in_two_days).len > 0
| Type | project | Subject | Created at | Link |
| ---- | ------- | ------- | ---------- | ---- |
@for story in stories.filter(it.category == .in_two_days)
| UserStory |$story.project().name | $story.subject | $story.created_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project().slug/us/$story.ref) |
@end
@for issue in issues.filter(it.category == .in_two_days)
| Issue |$issue.project().name | $issue.subject | $issue.created_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project().slug/issue/$issue.ref) |
@end
@for task in tasks.filter(it.category == .in_two_days)
| Task |$task.project().name | $task.subject | $task.created_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project().slug/task/$task.ref) |
@end
@else
- No stories, issues and tasks to be delivered in 2 days .
@end

## In Week
@if stories.filter(it.category == .in_week).len > 0 || issues.filter(it.category == .in_week).len > 0 || tasks.filter(it.category == .in_week).len > 0
| Type | project | Subject | Created at | Deadline | Link |
| ---- | ------- | ------- | ---------- | -------- | ---- |
@for story in stories.filter(it.category == .in_week)
| UserStory |$story.project().name | $story.subject | $story.created_date.ymmdd() | $story.due_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project().slug/us/$story.ref) |
@end
@for issue in issues.filter(it.category == .in_week)
| Issue |$issue.project().name | $issue.subject | $issue.created_date.ymmdd() | $issue.due_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project().slug/issue/$issue.ref) |
@end
@for task in tasks.filter(it.category == .in_week)
| Task |$task.project().name | $task.subject | $task.created_date.ymmdd() | $task.due_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project().slug/task/$task.ref) |
@end
@else
- No stories, issues and tasks to be delivered in a week.
@end

## In Month
@if stories.filter(it.category == .in_month).len > 0 || issues.filter(it.category == .in_month).len > 0 || tasks.filter(it.category == .in_month).len > 0
| Type | project | Subject | Created at | Deadline | Link |
| ---- | ------- | ------- | ---------- | -------- | ---- |
@for story in stories.filter(it.category == .in_month)
| UserStory |$story.project().name | $story.subject | $story.created_date.ymmdd() | $story.due_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project().slug/us/$story.ref) |
@end
@for issue in issues.filter(it.category == .in_month)
| Issue |$issue.project().name | $issue.subject | $issue.created_date.ymmdd() | $issue.due_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project().slug/issue/$issue.ref) |
@end
@for task in tasks.filter(it.category == .in_month)
| Task |$task.project().name | $task.subject | $task.created_date.ymmdd() | $task.due_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project().slug/task/$task.ref) |
@end
@else
- No stories, issues and tasks to be delivered in a month.
@end

@if stories.filter(it.category == .other).len > 0 || issues.filter(it.category == .other).len > 0 || tasks.filter(it.category == .other).len > 0
## Others
| Type | project | Subject | Created at | Link |
| ---- | ------- | ------- | ---------- | ---- |
@for story in stories.filter(it.category == .other)
| UserStory |$story.project().name | $story.subject | $story.created_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project().slug/us/$story.ref) |
@end
@for issue in issues.filter(it.category == .other)
| Issue |$issue.project().name | $issue.subject | $issue.created_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project().slug/issue/$issue.ref) |
@end
@for task in tasks.filter(it.category == .other)
| Task |$task.project().name | $task.subject | $task.created_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project().slug/task/$task.ref) |
@end
@end
@if stories.filter(it.category == .old).len > 0 || issues.filter(it.category == .old).len > 0 || tasks.filter(it.category == .old).len > 0
## Old
| Type | project | Subject | Created at | Deadline | Link |
| ---- | ------- | ------- | ---------- | -------- | ---- |
@for story in stories.filter(it.category == .old)
| UserStory |$story.project().name | $story.subject | $story.created_date.ymmdd() | $story.due_date.ymmdd() | [wiki](../stories/$story.file_name) \| [web](@url/project/$story.project().slug/us/$story.ref) |
@end
@for issue in issues.filter(it.category == .old)
| Issue |$issue.project().name | $issue.subject | $issue.created_date.ymmdd() | $issue.due_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project().slug/issue/$issue.ref) |
@end
@for task in tasks.filter(it.category == .old)
| Task |$task.project().name | $task.subject | $task.created_date.ymmdd() | $task.due_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project().slug/task/$task.ref) |
@end
@end
