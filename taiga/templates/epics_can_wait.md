

@if epics.len >0

### Epics
@for epic in epics
#### [$epic.subject](@circles_url/project/@project.slug/epic/$epic.ref)
|              |                                        |
| ------------ | -------------------------------------- |
| ID           | $epic.id                               |
| Story        | [${story.subject}](${story.file_name}) |
| Owner        | $epic.owner_extra_info.username        |
| Assigned to  | $epic.assigned_to_extra_info.username  |
| Private      | $epic.is_private                       |
| Closed       | $epic.is_closed                        |
| Created at   | $epic.created_date                     |
| Last Updates | $epic.modified_date                    |

@if epic.description != ""
##### Description
> Rendered as markdown

$epic.description

@end
---
@end
@end


>TODO: detail of epic + comments