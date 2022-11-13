const addicons = new AddIcons();
const icons = new Icons();
const cards = new Cards();
const translate = new Translator();
const glow = new Glow();
const infobox = new Infobox();
const navbar = new Navbar();
const sidebar = new Sidebar();
const tooltip = new Tooltip();
const iconloader = new IconLoader();

document.addEventListener('DOMContentLoaded', function() {
  iconloader.addIntersectionObserver();
  addicons.add();
  //Things to call when tab got resized
  window.addEventListener('resize', function() {
    icons.setIconWidths();
    sidebar.reset();
  });

  cards.build();

  document.getElementById("language-toggle").addEventListener("click", translate.toggle.bind(translate));

  glow.addMouseMoveListener();

  navbar.addIntersectionObserver();

  document.getElementById("menu").addEventListener("click", sidebar.toggle.bind(sidebar));

  tooltip.add();
}, false);
