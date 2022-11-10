class Icons {
	addIntersectionObserver() {
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
		// Adds observer to every icon
		for (var icon of document.querySelectorAll("#iconlist > .tiles > img")) {
	    observer.observe(icon);
	  }
	}
	//Calculates from min- and fullwidth how many icons can fit in a row
	//Returns number of icons that fit in a row
	calcIconsPerLine(fullwidth) {
		var minwidth = document.getElementById("menu").offsetWidth;
		return Math.floor(fullwidth / minwidth);
	}

	//Calculates the width to fill the full width
	//Get the number of icons in a row and the full width of the grid
	//Returns the width
	calcWidthPerIcon(number, fullwidth) {
		var width = fullwidth / number;
		return width;
	}

	//Sets the data for a single icon
	//Gets a icon, a width and an iconposition
	//Return nothing
	setIconData(icon, width, iconposition) {
			if ((icon.getAttribute("data-info")!=undefined||icon.getAttribute("data-author")!=undefined)&&icon.getAttribute("data-title")!=undefined) {
				icon.setAttribute("position", iconposition);
				icon.addEventListener("click", showInfo);
				icon.style.cursor = "pointer";
			}
			icon.style.width = `${width}px`;
			icon.style.height = `${width}px`;
	}

	//Sets the width for all icons and the infobox
	setIconWidths() {
		var fullwidth = document.querySelector(".tiles").offsetWidth;
		var number = this.calcIconsPerLine(fullwidth);
		var width = this.calcWidthPerIcon(number, fullwidth);
		//Sets the length
		//Note: length is 1 longer than actual length
		document.getElementById("iconlist").setAttribute("length", number + 1);
		//Used to indicate which infobox is opened
		var iconposition = 0;
		for (var list of document.querySelectorAll(".tiles")) {
			var icons = list.children;
			//Used to calc rows per list
			var totaliconsperlist = 0;
			for (var icon of icons) {
				if (!(icon.getAttribute("data-no-resize"))) {
					this.setIconData(icon, width, iconposition);
					var row = Math.floor(totaliconsperlist / number) + 1;
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
			list.style.setProperty("--columns", number);
		}
	}
}
