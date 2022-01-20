# [@user.username](@url/profile/@user.username)
- ID: @user.id
- Full name: @user.full_name
- Biography: @user.bio
- Email: @user.email
- Active state: @user.is_active

# Priorities
## Blocked
@if blocked.stories.len > 0 || blocked.issues.len > 0 || blocked.tasks.len > 0
| Type | project | Subject | Created at | Blocked Note | Link |
| ---- | ------- | ------- | ---------- | ------------ | ---- |
@for story in blocked.stories
| UserStory |$story.project_extra_info.name | $story.subject | $story.created_date.ymmdd() | $story.blocked_note | [wiki]($story.file_name) \| [web](@url/project/$story.project_extra_info.slug/us/$story.ref) |
@end
@for issue in blocked.issues
| Issue |$issue.project_extra_info.name | $issue.subject | $issue.created_date.ymmdd() | $issue.blocked_note | [wiki]($issue.file_name) \| [web](@url/project/$issue.project_extra_info.slug/issue/$issue.ref) |
@end
@for task in blocked.tasks
| Task |$task.project_extra_info.name | $task.subject | $task.created_date.ymmdd() | $task.blocked_note | [wiki]($task.file_name) \| [web](@url/project/$task.project_extra_info.slug/task/$task.ref) |
@end
@else
- No blocked stories, issues and tasks.
@end
## Overdue
@if overdue.stories.len > 0 || overdue.issues.len > 0 || overdue.tasks.len > 0
| Type | project | Subject | Created at | Deadline | Link |
| ---- | ------- | ------- | ---------- | -------- | ---- |
@for story in overdue.stories
| UserStory |$story.project_extra_info.name | $story.subject | $story.created_date.ymmdd() | $story.due_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project_extra_info.slug/us/$story.ref) |
@end
@for issue in overdue.issues
| Issue |$issue.project_extra_info.name | $issue.subject | $issue.created_date.ymmdd() | $issue.due_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project_extra_info.slug/issue/$issue.ref) |
@end
@for task in overdue.tasks
| Task |$task.project_extra_info.name | $task.subject | $task.created_date.ymmdd() | $task.due_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project_extra_info.slug/task/$task.ref) |
@end
@else
- No delayed stories, issues and tasks .
@end
## Today
@if today.stories.len > 0 || today.issues.len > 0 || today.tasks.len > 0
| Type | project | Subject | Created at | Link |
| ---- | ------- | ------- | ---------- | ---- |
@for story in today.stories
| UserStory |$story.project_extra_info.name | $story.subject | $story.created_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project_extra_info.slug/us/$story.ref) |
@end
@for issue in today.issues
| Issue |$issue.project_extra_info.name | $issue.subject | $issue.created_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project_extra_info.slug/issue/$issue.ref) |
@end
@for task in today.tasks
| Task |$task.project_extra_info.name | $task.subject | $task.created_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project_extra_info.slug/task/$task.ref) |
@end
@else
- No stories, issues and tasks to be delivered today .
@end
## In 2 Days
@if in_two_days.stories.len > 0 || in_two_days.issues.len > 0 || in_two_days.tasks.len > 0
| Type | project | Subject | Created at | Link |
| ---- | ------- | ------- | ---------- | ---- |
@for story in in_two_days.stories
| UserStory |$story.project_extra_info.name | $story.subject | $story.created_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project_extra_info.slug/us/$story.ref) |
@end
@for issue in in_two_days.issues
| Issue |$issue.project_extra_info.name | $issue.subject | $issue.created_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project_extra_info.slug/issue/$issue.ref) |
@end
@for task in in_two_days.tasks
| Task |$task.project_extra_info.name | $task.subject | $task.created_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project_extra_info.slug/task/$task.ref) |
@end
@else
- No stories, issues and tasks to be delivered in 2 days .
@end

## In Week
@if in_week.stories.len > 0 || in_week.issues.len > 0 || in_week.tasks.len > 0
| Type | project | Subject | Created at | Deadline | Link |
| ---- | ------- | ------- | ---------- | -------- | ---- |
@for story in in_week.stories
| UserStory |$story.project_extra_info.name | $story.subject | $story.created_date.ymmdd() | $story.due_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project_extra_info.slug/us/$story.ref) |
@end
@for issue in in_week.issues
| Issue |$issue.project_extra_info.name | $issue.subject | $issue.created_date.ymmdd() | $issue.due_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project_extra_info.slug/issue/$issue.ref) |
@end
@for task in in_week.tasks
| Task |$task.project_extra_info.name | $task.subject | $task.created_date.ymmdd() | $task.due_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project_extra_info.slug/task/$task.ref) |
@end
@else
- No stories, issues and tasks to be delivered in a week.
@end

## In Month
@if in_month.stories.len > 0 || in_month.issues.len > 0 || in_month.tasks.len > 0
| Type | project | Subject | Created at | Deadline | Link |
| ---- | ------- | ------- | ---------- | -------- | ---- |
@for story in in_month.stories
| UserStory |$story.project_extra_info.name | $story.subject | $story.created_date.ymmdd() | $story.due_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project_extra_info.slug/us/$story.ref) |
@end
@for issue in in_month.issues
| Issue |$issue.project_extra_info.name | $issue.subject | $issue.created_date.ymmdd() | $issue.due_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project_extra_info.slug/issue/$issue.ref) |
@end
@for task in in_month.tasks
| Task |$task.project_extra_info.name | $task.subject | $task.created_date.ymmdd() | $task.due_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project_extra_info.slug/task/$task.ref) |
@end
@else
- No stories, issues and tasks to be delivered in a month.
@end

@if others.stories.len > 0 || others.issues.len > 0 || others.tasks.len > 0
## Others
| Type | project | Subject | Created at | Link |
| ---- | ------- | ------- | ---------- | ---- |
@for story in others.stories
| UserStory |$story.project_extra_info.name | $story.subject | $story.created_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/$story.project_extra_info.slug/us/$story.ref) |
@end
@for issue in others.issues
| Issue |$issue.project_extra_info.name | $issue.subject | $issue.created_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project_extra_info.slug/issue/$issue.ref) |
@end
@for task in others.tasks
| Task |$task.project_extra_info.name | $task.subject | $task.created_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project_extra_info.slug/task/$task.ref) |
@end
@end
@if old.stories.len > 0 || old.issues.len > 0 || old.tasks.len > 0
## Old
| Type | project | Subject | Created at | Deadline | Link |
| ---- | ------- | ------- | ---------- | -------- | ---- |
@for story in old.stories
| UserStory |$story.project_extra_info.name | $story.subject | $story.created_date.ymmdd() | $story.due_date.ymmdd() | [wiki](../stories/$story.file_name) \| [web](@url/project/$story.project_extra_info.slug/us/$story.ref) |
@end
@for issue in old.issues
| Issue |$issue.project_extra_info.name | $issue.subject | $issue.created_date.ymmdd() | $issue.due_date.ymmdd() | [wiki]($issue.file_name) \| [web](@url/project/$issue.project_extra_info.slug/issue/$issue.ref) |
@end
@for task in old.tasks
| Task |$task.project_extra_info.name | $task.subject | $task.created_date.ymmdd() | $task.due_date.ymmdd() | [wiki]($task.file_name) \| [web](@url/project/$task.project_extra_info.slug/task/$task.ref) |
@end
@end
