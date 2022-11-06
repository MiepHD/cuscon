function calcWidth(minwidth, fullwidth) {
	number = Math.floor(fullwidth / minwidth);
	width = fullwidth / number;
	return width;
}

function setIconWidth(icon, width) {
		if ((icon.getAttribute("data-info")!=undefined||icon.getAttribute("data-author")!=undefined)&&icon.getAttribute("data-title")!=undefined) {
			icon.setAttribute("position", iconposition);
			icon.addEventListener("click", showInfo);
			icon.style.cursor = "pointer";
		}
		icon.style.width = `${width}px`;
		icon.style.height = `${width}px`;
}

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
function showInfo() {
	icon = this;
	newicon = icon.getAttribute("position");
	infobox = document.getElementById("infobox");
	infobox.style.transform = "scaleY(0)";
	setTimeout(function () {
		//Hides infobox when clicked again on the same icon
		if (currenticon==newicon) {
			infobox.style.display = "none";
			currenticon = undefined;
			return;
		}
		currenticon = newicon;
		
		infobox.style.display = "initial";
		infobox.style.setProperty("--length", document.getElementById("iconlist").getAttribute("length"));
		infobox.style.setProperty("--row", icon.getAttribute("row"));
		icon.parentElement.appendChild(infobox);
		setTimeout(function () {
			//Variables for info
			infoelement = document.getElementById("infobox-info");
			info = icon.getAttribute("data-info");

			//Variables for author
			authorelement = document.getElementById("infobox-author");
			author = icon.getAttribute("data-author");

			//Variables for icon-name
			titleelement = document.getElementById("infobox-title");
			title = icon.getAttribute("data-title");

			if (info==undefined) {
				infoelement.style.display = "none";
			} else {
				infoelement.innerHTML = info;
				infoelement.style.display = "block";
			}
			addTooltip();
			if (author==undefined) {
				authorelement.style.display = "none";
				titleelement.classList.add("no-author");
			} else {
				titleelement.classList.remove("no-author");
				authorelement.innerHTML = author;
				authorelement.href = `https://github.com/${author}`;
				authorelement.style.display = "block";
			}
			titleelement.textContent = title;
			infobox.style.transform = "scaleY(1)";
		}, transformtime);
	}, transformtime);
}
function addTooltip() {
  links = document.querySelectorAll("a.unavailable");
  for (link of links) {
    if (link.children[0]==undefined) {
			span = document.createElement("span");
      span.classList.add("unavailable-tooltip");
      span.textContent = "Coming soon";
			link.appendChild(span);
			span.style.marginLeft = `-${span.offsetWidth / 2}px`;
    }
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
currenticon = undefined;
transformtime = 200;
document.addEventListener('DOMContentLoaded', function() {
	// Add observer to every icon
	for (image of document.querySelectorAll("#iconlist > .tiles > img")) {
		observer.observe(image);
	}
	setIconWidths();
	addTooltip();
	//Things to call when tab got resized
	window.addEventListener('resize', function() {
		setIconWidths();
	});
}, false);
