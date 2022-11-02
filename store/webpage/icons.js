document.addEventListener('DOMContentLoaded', function() {
	const observer = new IntersectionObserver((entries) => {
		entries.forEach((entry) => {
			// changing opacity of element based on its visibility on the viewport
			if (entry.isIntersecting) {
				entry.target.style.top = 0;
			} else {
				//entry.target.style.top = 50;
			}
		});
	});
	// Create the intersection observer
	for (image of document.querySelectorAll("#iconlist > .tiles > img")) {
		observer.observe(image);
		console.info("Added observer")
	}
	function setIconWidths() {
		minwidth = document.getElementById("menu").offsetWidth;
		fullwidth = document.querySelector(".tiles").offsetWidth;
		number = Math.floor(fullwidth / minwidth);
		width = fullwidth / number;
		width = width - width / 17.84
		lists = document.querySelectorAll(".tiles");
		for (x of lists) {
			tiles = x.children;
			for (icon of tiles) {
				icon.style.width = width;
			}
		}
		console.log("resized")
	}
	window.addEventListener('resize', setIconWidths);
	setIconWidths();
}, false);