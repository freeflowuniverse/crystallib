```yaml

!!webdb.user_add
    name: 'John Doe'
    email: 'john.doe@example.com'
    description: 'Senior Developer'
    profile: 'Technical'
    admin: true

!!webdb.user_add
    name: 'Someone'
    email: me@example.com'
    admin: true

!!webdb.user_add
    email: jane.smith@example.com'


!!webdb.group_add
    name: 'Developers'
    users: 'john.doe@example.com,jane.smith@example.com'
    groups: 'Frontend,Backend'

!!webdb.group_add
    name: 'Frontend'
    users: 'john.doe@example.com'
    groups: 'Frontend,Backend'

!!webdb.group_add
    name: 'Backend'


!!webdb.acl_add
    name: 'ProjectX_ACL'

!!webdb.ace_add
    acl: 'ProjectX_ACL'
    group: 'Developers'
    user: 'john.doe@example.com'
    right: 'write'

!!webdb.ace_add
    acl: 'ProjectX_ACL'
    user: 'Someone'
    right: 'read'

!!webdb.infopointer_add
    name: 'ProjectX_Documentation'
    path: '/projects/X/docs'
    acl: 'ProjectX_ACL'
    description: '
        This is the main documentation for Project X.
        It contains all the necessary information for developers.
    '
    expiration: '2024-12-31'

!!webdb.webdb_create
    users: 'John Doe,Jane Smith'
    groups: 'Developers,Frontend,Backend'
    acls: 'ProjectX_ACL'
    infopointers: 'ProjectX_Documentation'
```