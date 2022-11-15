class Icons {
	addIntersectionObserver(div) {
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
					const icon = entry.target;
					icon.style.top = 0;
					observer.unobserve(icon);
				}
			});
		});
		// Adds observer to every icon
		for (const icon of div.children) {
	    observer.observe(icon);
	  }
	}
	//Calculates from min- and fullwidth how many icons can fit in a row
	//Returns number of icons that fit in a row
	calcIconsPerLine(fullwidth) {
		const minwidth = document.getElementById("menu").offsetWidth;
		return Math.floor(fullwidth / minwidth);
	}

	//Sets the data for a single icon
	//Gets a icon, a width and an iconposition
	//Return nothing
	setIconData(icon, width, iconposition) {
			if ((icon.getAttribute("data-info")!=undefined||icon.getAttribute("data-author")!=undefined)&&icon.getAttribute("data-title")!=undefined) {
				icon.setAttribute("position", iconposition);
				icon.addEventListener("click", infobox.show);
				icon.style.cursor = "pointer";
			}
			icon.style.width = `${width}px`;
			icon.style.height = `${width}px`;
	}

	//Sets the width for all icons and the infobox
	setIconWidths() {
		if (document.querySelector(".tiles")==undefined) {
			return;
		}
		const fullwidth = document.querySelector(".tiles").offsetWidth,
			number = this.calcIconsPerLine(fullwidth),
			width = fullwidth / number;
		//Sets the length
		//Note: length is 1 longer than actual length
		document.getElementById("iconlist").setAttribute("length", number + 1);
		//Used to indicate which infobox is opened
		let iconposition = 0;
		for (const list of document.querySelectorAll(".tiles")) {
			const icons = list.children;
			//Used to calc rows per list
			let totaliconsperlist = 1;
			for (const icon of icons) {
				if (!(icon.getAttribute("data-no-resize"))) {
					this.setIconData(icon, width, iconposition++);
					const row = Math.ceil(totaliconsperlist++ / number) + 1; //It should output the row under the current one
					icon.setAttribute("row", row);
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
