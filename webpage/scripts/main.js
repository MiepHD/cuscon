document.addEventListener('DOMContentLoaded', function() {
  const addicons = new AddIcons();
  addicons.add();

	const icons = new Icons();
  icons.addIntersectionObserver();
  icons.setIconWidths();
  //Things to call when tab got resized
  window.addEventListener('resize', function() {
    icons.setIconWidths();
  });

  const build = new Builder();
  build.cards();

  const translate = new Translator();
  document.getElementById("language-toggle").addEventListener("click", translate.toggle.bind(translate));
}, false);
