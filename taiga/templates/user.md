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

# Priorities (tasks, issues & stories)

## Blocked

//issues/stories which are in blocked mode

## Overdue 

//show issues and stories in table form which are overdue
//in tabel show: project (name only), title, creation time in human readable form (just month:day), deadline, link (link links to the issue/story on circles tool)

## Today

// what is there to do today

## In 2 days

## In 1 week

## In 1 month

## Later or No Deadline

## Old

// whatever is put in +2 months ago



