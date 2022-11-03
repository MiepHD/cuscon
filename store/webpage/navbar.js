document.addEventListener('DOMContentLoaded', function() {
	const observer = new IntersectionObserver((entries) => {
		entries.forEach((entry) => {
			// changing opacity of element based on its visibility on the viewport
			movingImage = document.querySelector("#iconwithname");
			if (entry.isIntersecting) {
				height = Math.ceil(movingImage.offsetHeight * -2);
				movingImage.style.top = `${height}px`;
			} else {
				movingImage.style.top = "0px";
			}
		});
	});
	// Create the intersection observer
	observer.observe(document.querySelector("#main-image"));
}, false);