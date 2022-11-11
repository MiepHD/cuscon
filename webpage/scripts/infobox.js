class Infobox {
	constructor() {
		this.currenticon = undefined;
		this.transformtime = 500;
	}
	setContent(icon) {
		//Variables for info
		const infoelement = document.getElementById("infobox-info"),
			info = icon.getAttribute("data-info"),

		//Variables for author
			authorelement = document.getElementById("infobox-author"),
			author = icon.getAttribute("data-author"),

		//Variables for title
		//Title should be filled but don't has to be
			titleelement = document.getElementById("infobox-title"),
			title = icon.getAttribute("data-title");

		//Sets title
		titleelement.innerHTML = title;
		titleelement.setAttribute("data-translation-id", title);

		//Sets info
		if (info==undefined) {
			infoelement.style.display = "none";
		} else {
			infoelement.innerHTML = info;
			infoelement.setAttribute("data-translation-id", info);
			infoelement.style.display = "block";
		}

		//Sets author (Only one supported)
		if (author==undefined) {
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
		const icon = this,
			box = document.getElementById("infobox");
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
			box.style.setProperty("--length", document.getElementById("iconlist").getAttribute("length"));
			box.style.setProperty("--row", icon.getAttribute("row"));
			icon.parentElement.appendChild(box);
			//Add tooltip for newly added HTML
			tooltip.add();
			box.style.display = "initial";
			//Actually show element
			setTimeout(function () { //Not sure why we have to wait here but when removed it instantly appears
				box.style.maxHeight = `${window.screen.availHeight}px`;
			}, infobox.transformtime);
		}, infobox.transformtime);
	}
}
