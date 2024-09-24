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

// Fetch documents when the DOM is fully loaded
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

    const row = `
      <tr>
        <td>${iconHTML}</td> <!-- Add the icon column -->
        <td>${doc.order}</td>
        <td><a href="${doc.url}" target="_blank">${doc.title}</a></td>
        <td>${doc.description}</td>
        <td>${doc.tags}</td>
        <td>${doc.creator}</td>
        <td>${doc.date_created}</td>
        <td>${doc.kind}</td>
      </tr>
    `;
    tbody.insertAdjacentHTML("beforeend", row);
  });
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

// Filter documents by tag or kind (kind)
function filterDocuments() {
  const filterType = document.getElementById("filterType").value;
  let filteredDocs = [];

  if (filterType === "tag") {
    const uniqueTags = [...new Set(documents.map((doc) => doc.tags))];
    uniqueTags.forEach((tag) => {
      filteredDocs.push(...documents.filter((doc) => doc.tags === tag));
    });
  } else if (filterType === "kind") {
    const uniquekinds = [...new Set(documents.map((doc) => doc.kind))];
    uniquekinds.forEach((kind) => {
      filteredDocs.push(...documents.filter((doc) => doc.kind === kind));
    });
  } else {
    filteredDocs = documents; // If 'all' is selected, show all documents
  }

  populateTable(filteredDocs);
}