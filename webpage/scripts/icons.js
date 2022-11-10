//Calculates the width to fill the full width
function calcWidth(minwidth, fullwidth) {
	number = Math.floor(fullwidth / minwidth);
	width = fullwidth / number;
	return width;
}

//Sets the width for a single icon
function setIconWidth(icon, width) {
		if ((icon.getAttribute("data-info")!=undefined||icon.getAttribute("data-author")!=undefined)&&icon.getAttribute("data-title")!=undefined) {
			icon.setAttribute("position", iconposition);
			icon.addEventListener("click", showInfo);
			icon.style.cursor = "pointer";
		}
		icon.style.width = `${width}px`;
		icon.style.height = `${width}px`;
}

//Sets the width for all icons and the infobox
function setIconWidths() {
	minwidth = document.getElementById("menu").offsetWidth;
	fullwidth = document.querySelector(".tiles").offsetWidth;
	width = calcWidth(minwidth, fullwidth);
	//Sets the length
	//Note: length is 1 longer than actual length
	document.getElementById("iconlist").setAttribute("length", number + 1);
	lists = document.querySelectorAll(".tiles");
	//Used to indicate which infobox is opened
	iconposition = 0;
	for (x of lists) {
		tiles = x.children;
		//Used to calc rows per list
		totaliconsperlist = 0;
		for (icon of tiles) {
			if (!(icon.getAttribute("data-no-resize"))) {
				setIconWidth(icon, width);
				row = Math.floor(totaliconsperlist / number) + 1;
				icon.setAttribute("row", row + 1);
				//Increment
				totaliconsperlist++;
				iconposition++;
			} else {
				//This "icon" is the infobox
				//Applies if infobox is shown while resizing
				icon.style.setProperty("--length", document.getElementById("iconlist").getAttribute("length"));
			}
		}
		//Declares columns for grid
		x.style.setProperty("--columns", number);
	}
}
const observer = new IntersectionObserver((entries) => {
	entries.forEach((entry) => {
		if (entry.isIntersecting) {
			//Move elements up when they get visible
			/*
			Problem:
			Icons move up when intersecting on the top of the screen.

			Reproduce:
			Can be reproduced through scrolling to the bottom and reloading the page.
			*/
			entry.target.style.top = 0;
		}
	});
});
document.addEventListener('DOMContentLoaded', function() {
	// Add observer to every icon
	for (image of document.querySelectorAll("#iconlist > .tiles > img")) {
		observer.observe(image);
	}
	setIconWidths();
	//Things to call when tab got resized
	window.addEventListener('resize', function() {
		setIconWidths();
	});
}, false);
