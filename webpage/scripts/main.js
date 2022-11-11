const addicons = new AddIcons();
const icons = new Icons();
const build = new Builder();
const xhttp = new XMLHttpRequest();
const translate = new Translator();
const glow = new Glow();
const infobox = new Infobox();
const navbar = new Navbar();
const sidebar = new Sidebar();
const tooltip = new Tooltip();

document.addEventListener('DOMContentLoaded', function() {
  addicons.add();

  icons.addIntersectionObserver();
  icons.setIconWidths();
  //Things to call when tab got resized
  window.addEventListener('resize', function() {
    icons.setIconWidths();
    sidebar.reset();
  });

  build.cards();

  document.getElementById("language-toggle").addEventListener("click", translate.toggle.bind(translate));

  glow.addMouseMoveListener();

  navbar.addIntersectionObserver();

  document.getElementById("menu").addEventListener("click", sidebar.toggle.bind(sidebar));

  tooltip.add();
}, false);
