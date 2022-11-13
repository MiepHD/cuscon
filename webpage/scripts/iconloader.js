class IconLoader {
  addIntersectionObserver() {
    let observer = new IntersectionObserver((entries) => {
			entries.forEach((entry) => {
				if (entry.isIntersecting) {
          const build = new IconBuilder();
          const category = entry.target;
          build.iconList(category.getAttribute("data-category-id"));
          observer.unobserve(category);
				}
			});
		});
		// Create the intersection observer
    for (const category of document.querySelectorAll("[data-category-id]")) {
		  observer.observe(category);
    }
  }
}
