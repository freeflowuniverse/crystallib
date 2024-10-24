module components

pub struct Row {
pub:
	cells []Cell
}

pub struct Cell {
pub:
	content string
}

pub struct Table {
pub:
	headers []string
	rows []Row
}

pub fn (table Table) html() string {
	headers := table.headers.map('<th>${it}</th>').join('')
	rows := table.rows.map(it.html()).join('\n')
	return '
	<!-- Table Section -->
  <style>
    /* Table container for scroll */
    #table-section {
      flex: 1;
      overflow-y: auto;
    }

    /* Style for the dropdown menu */
    .dropdown-menu {
      position: absolute;
      background-color: white;
      border-radius: 5px;
      padding: 0.5rem;
      display: none;
      /* Hidden by default */
      z-index: 10;
    }

    /* Show dropdown when parent is hovered */
    .icon-cell:hover .dropdown-menu {
      display: block;
    }

    /* Style for the ellipsis button */
    .icon-cell div {
      cursor: pointer;
    }

    /* Increase the size of the ellipsis icon */
    .icon-cell svg {
      width: 32px;
      /* Adjust width to make it larger */
      height: 32px;
      /* Adjust height to make it larger */
    }

    .dropdown-menu li {
      list-style: none;
    }

    .dropdown-menu li a {
      text-decoration: none;
      color: black;
    }

    .dropdown-menu li a:hover {
      color: #007bff;
      /* Optional hover effect */
    }
  </style>
	<table id="table">\n\t<thead>\n\t\t<tr>${headers}</tr>\n\t</thead>\n\t<tbody>\n${rows}\n\t</tbody>\n</table>'
}

pub fn (component Row) html() string {
	return "<tr>\n${component.cells.map(it.html()).join('\n')}\n</tr>"
}

pub fn (component Cell) html() string {
    return "<td>${component.content}</td>"
}