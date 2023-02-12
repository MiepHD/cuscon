const icons = new Icons();
const cards = new Cards();
const translate = new Translator();
const glow = new Glow();
const infobox = new Infobox();
const navbar = new Navbar();
const sidebar = new Sidebar();
const tooltip = new Tooltip();
const iconloader = new IconLoader();
const search = new Search();
const updater = new Updater();

document.addEventListener('DOMContentLoaded', () => {
  iconloader.load();
  sidebar.load();
  cards.build();
  $$("#language-toggle").addEventListener("click", translate.toggle.bind(translate));
  glow.addMouseMoveListener();
  navbar.addIntersectionObserver();
  $("#menu").width($("#placeholderformenu").height());
  $("#menu").height($("#placeholderformenu").height());
  $$("#menu").addEventListener("click", sidebar.toggle.bind(sidebar));
  tooltip.add();
  translate.renew();
  
  search.addEventListener();
}, false);
function $$(query) {
  const result = document.querySelectorAll(query);
  switch (result.length) {
    case 0: return undefined;
    case 1: return result[0];
    default: return result;
  }
}