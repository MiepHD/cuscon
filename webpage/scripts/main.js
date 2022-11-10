document.addEventListener('DOMContentLoaded', function() {
	icons = new Icons();
  icons.addIntersectionObserver();
  icons.setIconWidths();
  //Things to call when tab got resized
  window.addEventListener('resize', function() {
    icons.setIconWidths();
  });

  addicons = new AddIcons();
  addicons.add();

  build = new Builder();
  build.cards();
}, false);
