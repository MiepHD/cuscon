document.addEventListener('DOMContentLoaded', function() {
	const observer = new IntersectionObserver((entries) => {
		entries.forEach((entry) => {
			//Icon at the top left
			movingImage = document.querySelector("#iconwithname");
			if (entry.isIntersecting) {
				//Moves two times up
				height = Math.ceil(movingImage.offsetHeight * -2);
				movingImage.style.top = `${height}px`;
				showSidebar();
			} else {
				movingImage.style.top = "0px";
				hideSidebar();
			}
		});
	});
	// Create the intersection observer
	observer.observe(document.querySelector("#main-image"));
}, false);
