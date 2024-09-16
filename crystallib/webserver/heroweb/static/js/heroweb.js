function convertMarkdown(inputId, outputId, pointersListId = "") {
    const markdownInputElement = document.getElementById(inputId);
    if (!markdownInputElement) return;
    const markdownInput = markdownInputElement.value;
    const htmlOutput = marked.parse(markdownInput);
  
    const htmlOutputElement = document.getElementById(outputId);
    if (!htmlOutputElement) return;
    htmlOutputElement.innerHTML = htmlOutput;
  
    // Add IDs to headers if they don't have one
    const headers = htmlOutputElement.querySelectorAll("h1, h2");
    headers.forEach((header, index) => {
      if (!header.id) {
        header.id = `header-${index}`;
      }
    });
  
    // Generate content pointers if pointersListId is provided
    if (pointersListId) {
      const pointersList = document.getElementById(pointersListId);
      if (!pointersList) return;
      pointersList.innerHTML = "";
      headers.forEach((header) => {
        const li = document.createElement("li");
        const a = document.createElement("a");
        a.href = `#${header.id}`;
        a.textContent = header.textContent;
        li.appendChild(a);
        pointersList.appendChild(li);
      });
  
      // Add event listener to scroll to the section
      pointersList.querySelectorAll("a").forEach((anchor) => {
        anchor.addEventListener("click", (event) => {
          event.preventDefault();
          const targetId = anchor.getAttribute("href").substring(1);
          const targetElement = document.getElementById(targetId);
          if (targetElement) {
            targetElement.scrollIntoView({ behavior: "smooth" });
          }
        });
      });
    }
  }
  
  function initializeMarkdownConverter(inputId, outputId, pointersListId) {
    // Convert markdown immediately on page load
    convertMarkdown(inputId, outputId, pointersListId);
  
    // Add event listener to input for real-time conversion
    const inputElement = document.getElementById(inputId);
    if (inputElement) {
      inputElement.addEventListener("input", () => {
        convertMarkdown(inputId, outputId, pointersListId);
      });
    }
  }
  
  function addNavEventListeners() {
    const navItems = document.querySelectorAll("mynav ul li");
  
    navItems.forEach((item) => {
      const nestedList = item.querySelector("ul");
      if (nestedList) {
        // Add a visual cue for items with children
        const arrow = document.createElement("span");
        arrow.textContent = "▶"; // You can use any symbol or icon here
        arrow.classList.add("arrow");
        item.insertBefore(arrow, item.firstChild);
  
        // Add click event listener to toggle the nested list
        item.addEventListener("click", (event) => {
          event.stopPropagation(); // Prevent event from bubbling up
          item.classList.toggle("open");
          arrow.textContent = item.classList.contains("open") ? "▼" : "▶"; // Change the arrow direction
        });
      }
    });
  }
  
  // Call the initialization function when the DOM is loaded
  document.addEventListener("DOMContentLoaded", () => {
    createThemeIcons();
    initializeMarkdownConverter("markdown-input", "markdown-output", "content-pointers");
    initializeMarkdownConverter("markdown-nav", "mynav");
    addNavEventListeners();
  });
  
  function setTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme);
    localStorage.setItem("theme", theme);
    console.log(`Theme set to: ${theme}`);
    updateThemeIcon(theme);
  }
  
  function getSystemTheme() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }
  
  function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute("data-theme") || "light";
    const newTheme = currentTheme === "light" ? "dark" : "light";
    setTheme(newTheme);
  }
  
  function updateThemeIcon(theme) {
    const themeIcon = document.querySelector(".theme-icon");
    if (themeIcon) {
      themeIcon.innerHTML = theme === "light" ? getLightIconSVG() : getDarkIconSVG();
      themeIcon.setAttribute("title", `Switch to ${theme === "light" ? "dark" : "light"} theme`);
    }
  }
  
  function createThemeIcons() {
    const themeIconsHTML = `
      <div class="theme-icons">
        <span class="theme-icon" title="Toggle theme">
          ${getLightIconSVG()}
        </span>
      </div>
    `;
  
    const placeholder = document.getElementById("theme-switcher-icons");
    if (placeholder) {
      placeholder.innerHTML = themeIconsHTML;
    }
  
    // Add event listener for theme switching
    const themeIcon = document.querySelector(".theme-icon");
    if (themeIcon) {
      themeIcon.addEventListener("click", toggleTheme);
    }
  
    // Set initial icon based on current theme
    updateThemeIcon(document.documentElement.getAttribute("data-theme") || "light");
  }
  
  function getLightIconSVG() {
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
      <path d="M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zM2 13h2c.55 0 1-.45 1-1s-.45-1-1-1H2c-.55 0-1 .45-1 1s.45 1 1 1zm18 0h2c.55 0 1-.45 1-1s-.45-1-1-1h-2c-.55 0-1 .45-1 1s.45 1 1 1zM11 2v2c0 .55.45 1 1 1s1-.45 1-1V2c0-.55-.45-1-1-1s-1 .45-1 1zm0 18v2c0 .55.45 1 1 1s1-.45 1-1v-2c0-.55-.45-1-1-1s-1 .45-1 1zM5.99 4.58c-.39-.39-1.03-.39-1.41 0-.39.39-.39 1.03 0 1.41l1.06 1.06c.39.39 1.03.39 1.41 0s.39-1.03 0-1.41L5.99 4.58zm12.37 12.37c-.39-.39-1.03-.39-1.41 0-.39.39-.39 1.03 0 1.41l1.06 1.06c.39.39 1.03.39 1.41 0 .39-.39.39-1.03 0-1.41l-1.06-1.06zm1.06-10.96c.39-.39.39-1.03 0-1.41-.39-.39-1.03-.39-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06zM7.05 18.36c.39-.39.39-1.03 0-1.41-.39-.39-1.03-.39-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06z" />
    </svg>`;
  }
  
  function getDarkIconSVG() {
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
      <path d="M12 3c-4.97 0-9 4.03-9 9s4.03 9 9 9 9-4.03 9-9c0-.46-.04-.92-.1-1.36-.98 1.37-2.58 2.26-4.4 2.26-2.98 0-5.4-2.42-5.4-5.4 0-1.81.89-3.42 2.26-4.4-.44-.06-.9-.1-1.36-.1z" />
    </svg>`;
  }
  
  // Check for saved theme preference or use system theme
  const savedTheme = localStorage.getItem("theme");
  if (savedTheme) {
    setTheme(savedTheme);
  } else {
    setTheme(getSystemTheme());
  }
  
  // Listen for system theme changes
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", (e) => {
    setTheme(e.matches ? "dark" : "light");
  });