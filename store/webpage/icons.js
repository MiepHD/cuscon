function setIconWidths() {
	minwidth = document.getElementById("menu").offsetWidth;
	fullwidth = document.querySelector(".tiles").offsetWidth;
	number = Math.floor(fullwidth / minwidth);
	width = fullwidth / number;
	//width = width - width / 17.84;
	document.getElementById("iconlist").setAttribute("length", number + 1);
	lists = document.querySelectorAll(".tiles");
	iconposition = 0;
	currenticon = undefined;
	for (x of lists) {
		tiles = x.children;
		totaliconsperlist = 0;
		for (icon of tiles) {
			if ((icon.getAttribute("data-info")!=undefined||icon.getAttribute("data-author")!=undefined)&&icon.getAttribute("data-icon-name")!=undefined) {
				icon.setAttribute("position", iconposition);
				icon.addEventListener("click", showInfo);
				icon.style.cursor = "pointer";
			}
			icon.style.width = `${width}px`;
			icon.style.height = `${width}px`;
			row = Math.floor(totaliconsperlist / number) + 1;
			icon.setAttribute("row", row + 1);
			totaliconsperlist = totaliconsperlist + 1;
			iconposition = iconposition + 1;
		}
		x.style.setProperty("--columns", number);
		x.style.setProperty("--rows", Math.ceil(totaliconsperlist / number));
	}
}
function showInfo() {
	icon = this;
	newicon = icon.getAttribute("position");
	infobox = document.getElementById("infobox");
	infobox.style.transform = "scaleY(0)";
	setTimeout(displayBox, 100);
}
function displayBox() {
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
		title = icon.getAttribute("data-icon-name");

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
	}, 100);
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
	}
	window.addEventListener('resize', setIconWidths);
	setIconWidths();
	addTooltip();
}, false);
