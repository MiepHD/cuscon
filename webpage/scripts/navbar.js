class Navbar {
	addIntersectionObserver() {
		const observer = new IntersectionObserver((entries) => {
			entries.forEach((entry) => {
				//Icon at the top left
				const movingImage = document.querySelector("#iconwithname");
				if (entry.isIntersecting) {
					//Moves two times up
					const height = Math.ceil(movingImage.offsetHeight * -2);
					movingImage.style.top = `${height}px`;
					sidebar.show();
				} else {
					movingImage.style.top = "0px";
					sidebar.hide();
				}
			});
		});
		// Create the intersection observer
		observer.observe(document.querySelector("#main-image"));
	}
}
