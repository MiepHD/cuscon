function showInfo() {
	icon = this;
	infobox = document.getElementById("infobox");

	//Hide box on old place
	infobox.style.transform = "scaleY(0)";
	setTimeout(function () { //Wait 'til scaling is finished
		//Completely hides infobox when clicked again on the same icon
		newicon = icon.getAttribute("position");
		if (currenticon==newicon) {
			infobox.style.display = "none";
			currenticon = undefined;
			return;
		}
		currenticon = newicon;

		//Variables for info
		infoelement = document.getElementById("infobox-info");
		info = icon.getAttribute("data-info");

		//Variables for author
		authorelement = document.getElementById("infobox-author");
		author = icon.getAttribute("data-author");

		//Variables for title
		//Title should be filled but don't has to be
		titleelement = document.getElementById("infobox-title");
		title = icon.getAttribute("data-title");
		titleelement.innerHTML = title;

		if (info==undefined) {
			infoelement.style.display = "none";
		} else {
			infoelement.innerHTML = info;
			infoelement.style.display = "block";
		}
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
		if (language=="de") {
			translate();
		}
		//Add tooltip for newly added HTML
		addTooltip();
		//Move to right location and "show" the box. Note: scaleY still 0
		infobox.style.setProperty("--length", document.getElementById("iconlist").getAttribute("length"));
		infobox.style.setProperty("--row", icon.getAttribute("row"));
		icon.parentElement.appendChild(infobox);
		infobox.style.display = "initial";
		//Actually show element
		setTimeout(function () { //Not sure why we have to wait here but when removed it instantly appears
			infobox.style.transform = "scaleY(1)";
		}, transformtime);
	}, transformtime);
}
