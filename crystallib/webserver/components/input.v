module components

pub struct Dropdown{
pub:
	label string
	items []NavItem
}

pub fn (dropdown Dropdown) html() string {
	items := dropdown.items.map('<li><a href="${it.href}">${it.text}</a></li>')
	return '
	<details class="dropdown">
		<summary>${dropdown.label}</summary>
		<ul>${items.join('\n')}</ul>
	</details>
'
}

pub struct Select {
pub:
	name string
	options []Opt
}

pub fn (input Select) html() string {
	options := input.options.map(it.html()).join('\n')
	return '<select name="tag" up-change up-target="#table">\n${options}\n</select>'
}

pub struct Opt {
pub:
	content string
	value string
}

pub fn (option Opt) html() string {
    return '<option value="${option.value}">${option.content}</option>'
}