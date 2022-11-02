document.addEventListener('DOMContentLoaded', function() {
	const observer = new IntersectionObserver((entries) => {
		entries.forEach((entry) => {
			// changing opacity of element based on its visibility on the viewport
			movingImage = document.querySelector("#iconwithname");
			if (entry.isIntersecting) {
				movingImage.style.top = movingImage.offsetHeight * -2;
			} else {
				movingImage.style.top = 0;
			}
		});
	});
	// Create the intersection observer
	observer.observe(document.querySelector("#main-image"));
	//recalculateMenu()
}, false);
//window.addEventListener('resize', recalculateMenu);
//function recalculateMenu() {
//	document.querySelector("#menu").style.setProperty("--multiplicator", document.querySelector("body").offsetWidth / 1000);
//}