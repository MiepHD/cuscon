class Infobox {
	constructor() {
		this.currenticon = undefined;
		this.transformtime = 500;
	}
	setContent(icon) {
		//Variables for info
		const infoelement = $$("#infobox-info"),
			info = icon.getAttribute("data-info"),

		//Variables for author
			authorelement = $$("#infobox-author"),
			author = icon.getAttribute("data-author"),

		//Variables for title
		//Title should be filled but don't has to be
			titleelement = $$("#infobox-title"),
			title = icon.getAttribute("data-title");

		//Sets title
		titleelement.innerHTML = title;
		titleelement.setAttribute("data-translation-id", title);

		//Sets info
		if (!(info)) {
			infoelement.style.display = "none";
		} else {
			infoelement.innerHTML = info;
			infoelement.setAttribute("data-translation-id", info);
			infoelement.style.display = "block";
		}

		//Sets author (Only one supported)
		if (!(author)) {
			authorelement.style.display = "none";
			//let title fill full width
			titleelement.classList.add("no-author");
		} else {
			titleelement.classList.remove("no-author");
			authorelement.innerHTML = author;
			authorelement.href = `https://github.com/${author}`;
			authorelement.style.display = "block";
		}
	}
	show() {
		const icon = this;
		let box;
		if ($$("#infobox")) {
			box = $$("#infobox");
		} else {
			//const box = $("<div data-no-resize=true id='infobox'><div class='card'><h4 id='infobox-title'></h4><p id='infobox-info'></p><a id='infobox-author'></a></div></div>");
			box = document.createElement("div");
			box.setAttribute("data-no-resize", "true");
			box.setAttribute("id", "infobox");
			box.innerHTML = "<div class='card'><div class='card-content' data-translation-id='null'><h4 id='infobox-title'></h4><p id='infobox-info'></p><a id='infobox-author'></a></div></div>";
			$$("#iconlist").appendChild(box);
		}
		//Hide box on old place
		box.style.maxHeight = "0px";
		setTimeout(function () { //Wait 'til scaling is finished
			//Completely hides infobox when clicked again on the same icon
			const newicon = icon.getAttribute("position");
			if (infobox.currenticon==newicon) {
				box.style.display = "none";
				infobox.currenticon = undefined;
				return;
			}
			infobox.currenticon = newicon;
			infobox.setContent(icon);
			translate.renew();
			//Move to right location and "show" the box. Note: maxHeight still 0
			box.style.setProperty("--row", icon.getAttribute("row"));
			icon.parentElement.appendChild(box);
			box.style.display = "initial";
			//Actually show element
			setTimeout(function () { //Not sure why we have to wait here but when removed it instantly appears
				box.style.maxHeight = `${window.screen.availHeight}px`;
			}, infobox.transformtime);
		}, infobox.transformtime);
	}
}
