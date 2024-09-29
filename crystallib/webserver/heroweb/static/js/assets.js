let documents = []; // Initialize documents array

let currentSortDirection = {
  column: null,
  ascending: true,
};

// Icons for different kinds of assets
const kindIcons = {
  'html': '<i class="fas fa-code"></i>',
  'slides': '<i class="fas fa-chalkboard-teacher"></i>',
  'pdf': '<i class="fas fa-file-pdf"></i>',
  'wiki': '<i class="fas fa-book"></i>',
  'website': '<i class="fas fa-globe"></i>',
  'folder': '<i class="fas fa-folder"></i>'
};

document.addEventListener("DOMContentLoaded", function () {
  fetchDocuments();
});

// Fetch documents from the server endpoint
async function fetchDocuments() {
  try {
    const response = await fetch('/assets'); // Your endpoint for documents
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    documents = await response.json();
    populateTable(documents); // Populate the table with fetched documents
    populateTagCheckboxes(); // Populate the tag filter dropdown with checkboxes
  } catch (error) {
    console.error('Error fetching documents:', error);
  }
}

// Populate table with document data and add icons for each kind
function populateTable(data) {
  const tbody = document.getElementById("documentsBody");
  tbody.innerHTML = ""; // Clear the table body

  data.forEach((doc) => {
    // Define the icon based on document kind
    const iconHTML = kindIcons[doc.kind] || '';

    // Ensure tags are handled correctly (if it's an array, join into a string)
    const tagHTML = Array.isArray(doc.tags)
      ? doc.tags.map(tag => `<span class="tag" onclick="filterByClickedTag('${tag.trim()}')">${tag.trim()}</span>`).join(', ')
      : '';

    const row = `
      <tr>
        <td>${iconHTML}</td> <!-- Add the icon column -->
        <td><a href="${doc.url}" target="_blank">${doc.title}</a></td>
        <td>${doc.description}</td>
        <td>${tagHTML}</td>
        <td>${doc.kind}</td>
      </tr>
    `;
    tbody.insertAdjacentHTML("beforeend", row);
  });
}

// Populate tag checkboxes in the filter dropdown
function populateTagCheckboxes() {
  const tagCheckboxes = document.getElementById("tagCheckboxes");
  const uniqueTags = [...new Set(documents.flatMap(doc => Array.isArray(doc.tags) ? doc.tags : []))];

  tagCheckboxes.innerHTML = ''; // Clear any existing checkboxes
  uniqueTags.forEach((tag) => {
    const listItem = document.createElement("li");
    const label = document.createElement("label");
    label.innerHTML = `
      <input type="checkbox" name="${tag}" value="${tag}" onchange="filterByTags()" />
      ${tag}
    `;
    listItem.appendChild(label);
    tagCheckboxes.appendChild(listItem);
  });
}

// Filter documents by selected tags
function filterByTags() {
  const selectedTags = Array.from(document.querySelectorAll('#tagCheckboxes input[type="checkbox"]:checked')).map(checkbox => checkbox.value);
  const filteredDocs = documents.filter(doc => selectedTags.every(tag => Array.isArray(doc.tags) && doc.tags.includes(tag)));
  populateTable(filteredDocs);
}

// Filter documents when a tag is clicked in the table
function filterByClickedTag(tag) {
  const checkboxes = document.querySelectorAll('#tagCheckboxes input[type="checkbox"]');
  checkboxes.forEach(checkbox => {
    checkbox.checked = checkbox.value === tag;
  });
  filterByTags(); // Apply the filter
}

// Sort table based on column index
function sortTable(columnIndex) {
  const tbody = document.getElementById("documentsBody");
  let rowsArray = Array.from(tbody.rows);

  const isAscending = currentSortDirection.column === columnIndex && !currentSortDirection.ascending;
  currentSortDirection.column = columnIndex;
  currentSortDirection.ascending = isAscending;

  rowsArray.sort((rowA, rowB) => {
    const cellA = rowA.cells[columnIndex].textContent;
    const cellB = rowB.cells[columnIndex].textContent;

    if (isNaN(cellA) || isNaN(cellB)) {
      // Compare text
      return isAscending ? cellB.localeCompare(cellA) : cellA.localeCompare(cellB);
    } else {
      // Compare numbers
      return isAscending ? cellB - cellA : cellA - cellB;
    }
  });

  rowsArray.forEach((row) => tbody.appendChild(row));
}