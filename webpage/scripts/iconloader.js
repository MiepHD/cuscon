class IconLoader {
  addIntersectionObserver() {
    const observer = new IntersectionObserver((entries) => {
			entries.forEach((entry) => {
				if (entry.isIntersecting) {
          const build = new IconBuilder();
          build.iconList(entry.target.getAttribute("data-category-id"));
				}
			});
		});
		// Create the intersection observer
    for (const category of document.querySelectorAll("[data-category-id]")) {
		  observer.observe(category);
    }
  }
}
