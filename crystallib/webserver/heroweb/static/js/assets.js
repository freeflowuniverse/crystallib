let documents = []; // Initialize documents array

let currentSortDirection = {
  column: null,
  ascending: true,
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

// Populate table with document data
function populateTable(data) {
  const tbody = document.getElementById("documentsBody");
  tbody.innerHTML = ""; // Clear the table body

  data.forEach((doc) => {
    const row = `
      <tr>
        <td>${doc.order}</td>
        <td><a href="${doc.url}" target="_blank">${doc.title}</a></td>
        <td>${doc.description}</td>
        <td>${doc.tags}</td>
        <td>${doc.creator}</td>
        <td>${doc.date_created}</td>
        <td>${doc.format}</td>
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

// Filter documents by tag or kind (format)
function filterDocuments() {
  const filterType = document.getElementById("filterType").value;
  let filteredDocs = [];

  if (filterType === "tag") {
    const uniqueTags = [...new Set(documents.map((doc) => doc.tags))];
    uniqueTags.forEach((tag) => {
      filteredDocs.push(...documents.filter((doc) => doc.tags === tag));
    });
  } else if (filterType === "kind") {
    const uniqueFormats = [...new Set(documents.map((doc) => doc.format))];
    uniqueFormats.forEach((format) => {
      filteredDocs.push(...documents.filter((doc) => doc.format === format));
    });
  } else {
    filteredDocs = documents; // If 'all' is selected, show all documents
  }

  populateTable(filteredDocs);
}