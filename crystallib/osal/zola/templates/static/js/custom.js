var displayedMenu = "";
var hamburgerShown = false;
let width = screen.width;
var isMobile = width < 1024;

function toggleMenu(button) {
  if (displayedMenu === button.id.split("-")[0]) {
    button.className = button.className.replace(
      " text-blue-500 bg-stone-200 sm:bg-transparent",
      " text-gray-900"
    );
    hideMenu(button.id.split("-")[0]);
    button.lastElementChild.className = button.lastElementChild.className.replace(
      "rotate-0",
      "-rotate-90"
    );
    displayedMenu = "";
  } else {
    showMenu(button.id.split("-")[0]);
    button.lastElementChild.className = button.lastElementChild.className.replace(
      "-rotate-90",
      "rotate-0"
    );
    button.className = button.className.replace(
      " text-gray-900",
      " text-blue-500 bg-stone-200 sm:bg-transparent"
    );
    displayedMenu = button.id.split("-")[0];
  }
}

function handleClick(button) {
  if (button.id === "hamburger-btn" || button.id === "close-hamburger-btn") {
    toggleHamburger();
  }
  if (button.id.indexOf("menu") !== -1) {
    toggleMenu(button);
  }
}

function toggleHamburger() {
  if (hamburgerShown) {
    hideHamburger();
    hamburgerShown = false;
  } else {
    showHamburger();
    hamburgerShown = true;
  }
}

function showMenu(menuName) {
  var menuId = menuName + (isMobile ? "-mobile-menu" : "-menu");
  var menuBtnId = menuName + (isMobile ? "-mobile-menu" : "-menu");
  var menuElement = document.getElementById(menuId);
  menuElement.className = menuElement.className.replace(" hidden", "");
  setTimeout(function () {
    menuElement.className = menuElement.className.replace(
      "duration-200 ease-in opacity-0 -translate-y-1",
      "duration-150 ease-out opacity-1 -translate-y-0"
    );
  }, 10);
}

function hideMenu(menuName) {
  var menuId = menuName + (isMobile ? "-mobile-menu" : "-menu");
  var menuElement = document.getElementById(menuId);
  menuElement.className = menuElement.className.replace(
    "duration-150 ease-out opacity-1 -translate-y-0",
    "duration-200 ease-in opacity-0 -translate-y-1"
  );
  setTimeout(function () {
    menuElement.className = menuElement.className + " hidden";
  }, 300);
}

function showHamburger() {
  document.getElementById("header-container").className = "overflow-hidden";
  document.getElementById("hamburger").className =
    "fixed mt-2 z-20 top-0 inset-x-0 transition transform origin-top-right";
  document.getElementById("hamburger-btn").className =
    "hidden lg:hidden inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:bg-gray-100 focus:text-gray-500 transition duration-150 ease-in-out my-2";
  document.getElementById("close-hamburger-btn").className =
    "inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:bg-gray-100 focus:text-gray-500 transition duration-150 ease-in-out my-2";
}

function hideHamburger() {
  document.getElementById("header-container").className = "";
  document.getElementById("hamburger").className =
    "hidden absolute z-20 top-0 inset-x-0 transition transform origin-top-right lg:hidden";
  document.getElementById("hamburger-btn").className =
    "inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:bg-gray-100 focus:text-gray-500 transition duration-150 ease-in-out my-2";
  document.getElementById("close-hamburger-btn").className =
    "hidden lg:hidden inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:bg-gray-100 focus:text-gray-500 transition duration-150 ease-in-out my-2";
  if (displayedMenu !== "") {
    hideMenu(displayedMenu);
  }
}

window.onload = function () {
  let elements = document.getElementsByTagName("button");
  let buttons = [...elements];
  buttons.forEach((button) => {
    button.addEventListener("click", function () {
      handleClick(button);
    });
  });
  document
    .getElementById("mobile-learn-btn")
    ?.addEventListener("click", toggleMenu);
};
